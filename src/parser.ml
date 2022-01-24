open Core
open Types

type xml_tree = XMLElement of Xmlm.tag * xml_tree list | XMLData of string

type parse_options = ParseOptions of parse_options_t
 and parse_options_t = {
   parse_nodes: bool;
   parse_ways: bool;
   parse_relations: bool
 }

let default_parse_opts =
  ParseOptions {parse_nodes=true;
                parse_ways=true;
                parse_relations=true}

let input_tree xml_input =
  let el tag children = XMLElement (tag, children) in
  let data d = XMLData d in
  Xmlm.input_tree ~el ~data xml_input

let find_attr attrs attr =
  let check_attr ((_, name), _) = String.equal name attr in
  match List.find attrs ~f:check_attr with
  | Some v -> Some (snd v)
  | None -> None

let required_attr attrs attr =
  match find_attr attrs attr with
  | Some v -> v
  | None -> failwith "Cannot find required tag attribute"

let parse_tags xml_children =
  let parse_tag tags xml_child = match xml_child with
    | XMLElement (((_, "tag"), attrs), _) ->
       let k = (required_attr attrs "k") in
       let v = (required_attr attrs "v") in
       (add_tag tags k v)
    | _ -> tags in
  List.fold_left xml_children ~init:empty_tags ~f:parse_tag

let parse_node xml_input =
  match (input_tree xml_input) with
  | XMLElement (tag, children) ->
     let _, attrs = tag in
     let tags = parse_tags children in
     let lookup_attr = required_attr attrs in
     let node = OSMNode {
                    id=OSMId (lookup_attr "id");
                    latitude=lookup_attr "lat" |> Float.of_string;
                    longitude=lookup_attr "lon" |> Float.of_string;
                    version=lookup_attr "version";
                    changeset=lookup_attr "changeset";
                    user=lookup_attr "user";
                    uid=lookup_attr "uid";
                    timestamp=lookup_attr "timestamp";
                    tags=tags} in
     Some node
  | _ -> None

let parse_way xml_input =

  let parse_nds xml_children =
    let parse_nd nds xml_child = match xml_child with
      | XMLElement (((_, "nd"), attrs), _) ->
         let osm_id = (required_attr attrs "ref") in
         OSMId osm_id :: nds
      | _ -> nds in
    List.fold_left xml_children ~init:[] ~f:parse_nd |> List.rev in

  match (input_tree xml_input) with
  | XMLElement (tag, children) ->
     let _, attrs = tag in
     let tags = parse_tags children in
     let nds = parse_nds children in
     let lookup_attr = required_attr attrs in
     let way = OSMWay {
                   id=OSMId (lookup_attr "id");
                   version=lookup_attr "version";
                   changeset=lookup_attr "changeset";
                   user=lookup_attr "user";
                   uid=lookup_attr "uid";
                   timestamp=lookup_attr "timestamp";
                   tags=tags;
                   nodes=nds} in
     Some way
  | _ -> None

let parse_relation xml_input =

  let parse_members xml_children =
    let parse_member members xml_child = match xml_child with
      | XMLElement (((_, "member"), attrs), _) ->
         let type_ = (required_attr attrs "type") in
         let osm_id = (required_attr attrs "ref") in
         let role = (required_attr attrs "role") in
         let member = OSMRelationMember {ref=OSMId osm_id;
                                         type_=type_;
                                         role=role} in
         member :: members
      | _ -> members in
    List.fold_left xml_children ~init:[] ~f:parse_member |> List.rev in

  match (input_tree xml_input) with
  | XMLElement (tag, children) ->
     let _, attrs = tag in
     let tags = parse_tags children in
     let members = parse_members children in
     let lookup_attr = required_attr attrs in
     let relation = OSMRelation {
                        id=OSMId (lookup_attr "id");
                        version=lookup_attr "version";
                        changeset=lookup_attr "changeset";
                        user=lookup_attr "user";
                        uid=lookup_attr "uid";
                        timestamp=lookup_attr "timestamp";
                        tags=tags;
                        members=members} in
     Some relation
  | _ -> None

let parse_feature ((OSM osm) as osm')
                  (ParseOptions
                     {parse_nodes=parse_nodes;
                      parse_ways=parse_ways;
                      parse_relations=parse_relations})
                  xml_input =
  match (Xmlm.peek xml_input) with
  | `El_start ((_, tag_name), _) ->
     (match tag_name with
      | "node" when parse_nodes ->
         (match parse_node xml_input with
          | None -> osm'
          | Some (OSMNode node) ->
             OSM {nodes=OSMMap.add_exn osm.nodes ~key:node.id ~data:(OSMNode node);
                  ways=osm.ways;
                  relations=osm.relations})
      | "way" when parse_ways ->
         (match parse_way xml_input with
          | None -> osm'
          | Some (OSMWay way) ->
             OSM {nodes=osm.nodes;
                  ways=OSMMap.add_exn osm.ways ~key:way.id ~data:(OSMWay way);
                  relations=osm.relations})
      | "relation" when parse_relations ->
         (match parse_relation xml_input with
          | None -> osm'
          | Some (OSMRelation relation) ->
             OSM {nodes=osm.nodes;
                  ways=osm.ways;
                  relations=OSMMap.add_exn osm.relations ~key:relation.id
                                       ~data:(OSMRelation relation)})
      | _ ->
         ignore (Xmlm.input xml_input);
         osm')
  | _ ->
     ignore (Xmlm.input xml_input);
     osm'

let parse_file ?parse_opts:(parse_opts=default_parse_opts) filename =

  let rec parse_file_helper xml_input osm =
    match Xmlm.eoi xml_input with
      | true -> osm
      | false ->
         let new_osm = parse_feature osm parse_opts xml_input in
         parse_file_helper xml_input new_osm
  in
  let in_chan = In_channel.create filename in
  try
    let xml_input = Xmlm.make_input (`Channel in_chan) in
    let empty_osm = OSM {nodes = OSMMap.empty;
                         ways = OSMMap.empty;
                         relations = OSMMap.empty} in
    let osm = parse_file_helper xml_input empty_osm in
    In_channel.close in_chan;
    osm
  with e ->
    In_channel.close in_chan;
    raise e
