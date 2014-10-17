open Core.Std
open Types
open Xmlm

type xml_tree = XMLElement of Xmlm.tag * xml_tree list | XMLData of string

let input_tree xml_input =
  let el tag children = XMLElement (tag, children) in
  let data d = XMLData d in
  Xmlm.input_tree ~el ~data xml_input

let find_attr attrs attr =
  let check_attr = function
    | ((_, name), _) -> String.equal name attr
    | _ -> false in
  match List.find attrs check_attr with
  | Some v -> Some (snd v)
  | None -> None

let required_attr attrs attr =
  match find_attr attrs attr with
  | Some v -> v
  | None -> failwith "Cannot find required tag attribute"

let parse_tags xml_children =
  let parse_tag tags xml_child = match xml_child with
    | XMLElement (((_, "tag"), attrs), children) ->
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
      | XMLElement (((_, "nd"), attrs), children) ->
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
  failwith "not implemented"

let handle_xml_element xml_input =
  match (Xmlm.peek xml_input) with
  | `El_start ((_, tag_name), _) ->
     (match tag_name with
      | "node" -> parse_node xml_input
      | "way" -> parse_way xml_input
      | "relation" -> parse_relation xml_input
      | _ -> None)
  | _ ->
     ignore (Xmlm.input xml_input);
     None

let parse_file filename =
  let rec parse_file_helper xml_input osm =
    match Xmlm.eoi xml_input with
      | true -> osm
      | false ->
         let new_osm = match handle_xml_element xml_input with
           | Some a -> add_to_osm osm a
           | None -> osm in
         parse_file_helper xml_input new_osm in
  let in_chan = open_in filename in
  try
    let xml_input = Xmlm.make_input (`Channel in_chan) in
    let empty_osm = OSM {nodes = OSMMap.empty;
                         ways = OSMMap.empty;
                         relations = OSMMap.empty} in
    let osm = parse_file_helper xml_input empty_osm in
    In_channel.close in_chan;
    osm
  with e ->
    close_in_noerr in_chan;
    raise e
