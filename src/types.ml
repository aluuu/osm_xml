open Core.Std

type osm_id = OSMId of string

module StringMap = Map.Make (String)

type osm_tags = string StringMap.t

let empty_tags = StringMap.empty

let add_tag tags key value= StringMap.add tags key value

let find_tag tags key = StringMap.find tags key

module OSMId_S =
  struct
    type t = osm_id
    let compare = fun (OSMId a) (OSMId b) -> String.compare a b
    let sexp_of_t = fun (OSMId a) -> String.sexp_of_t a
    let t_of_sexp = fun a -> OSMId (String.t_of_sexp a)
  end

module OSMMap = Map.Make (OSMId_S)

type osm_node = OSMNode of osm_node_t
 and osm_node_t = {
  id: osm_id;
  latitude: float;
  longitude: float;
  version: string;
  changeset: string;
  user: string;
  uid: string;
  timestamp: string;
  tags: osm_tags;
}

type osm_way = OSMWay of osm_way_t
 and osm_way_t = {
  id: osm_id;
  version: string;
  changeset: string;
  user: string;
  uid: string;
  timestamp: string;
  tags: osm_tags;
  nodes: osm_id list;
}

type osm_relation_member = OSMRelationMember of osm_relation_member_t
 and osm_relation_member_t = {
   ref: osm_id;
   type_: string;
   role: string
}

type osm_relation = OSMRelation of osm_relation_t
 and osm_relation_t = {
  id: osm_id;
  version: string;
  changeset: string;
  user: string;
  uid: string;
  timestamp: string;
  tags: osm_tags;
  members: osm_relation_member list
}

type osm = OSM of osm_t
 and osm_t = {
   nodes: osm_node OSMMap.t;
   ways: osm_way OSMMap.t;
   relations: osm_relation OSMMap.t
 }

type osm_feature =
    OSMNode of osm_node_t |
    OSMWay of osm_way_t |
    OSMRelation of osm_relation_t

let empty_osm =
  OSM {nodes=OSMMap.empty;
       ways=OSMMap.empty;
       relations=OSMMap.empty}

let add_to_osm (OSM osm) element =
  match element with
  | (OSMNode node) ->
     OSM {nodes=OSMMap.add osm.nodes node.id (OSMNode node);
          ways=osm.ways;
          relations=osm.relations}
  | (OSMWay way) ->
     OSM {nodes=osm.nodes;
          ways=OSMMap.add osm.ways way.id (OSMWay way);
           relations=osm.relations}
  | (OSMRelation relation) ->
     OSM {nodes=osm.nodes;
          ways=osm.ways;
          relations=OSMMap.add osm.relations relation.id (OSMRelation relation)}
