open Core.Std

type osm_id = OSMId of string

module StringMap = Map.Make (String)

type osm_tags = string StringMap.t

let empty_tags = StringMap.empty

let add_tag tags key value= StringMap.add tags key value

let find_tag tags key = StringMap.find tags key

module OSMId_Comparator = struct
  module T =
    struct
      type t = osm_id
      let compare = fun (OSMId a) (OSMId b) -> String.compare a b
      let sexp_of_t = fun (OSMId a) -> String.sexp_of_t a
      let t_of_sexp = fun a -> OSMId (String.t_of_sexp a)
    end
  include T
  include Comparator.Make(T)
end

module OSMMap = Map.Make_using_comparator (OSMId_Comparator)

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

let empty_osm =
  OSM {nodes=OSMMap.empty;
       ways=OSMMap.empty;
       relations=OSMMap.empty}
