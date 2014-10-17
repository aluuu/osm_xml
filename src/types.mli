type osm_id = OSMId of string

module StringMap: Core.Std.Map.S

type osm_tags = string StringMap.t

val empty_tags: osm_tags

val add_tag: osm_tags -> string -> string -> osm_tags

val find_tag: osm_tags -> string -> string option

module OSMId_S :
  sig
    type t = osm_id
    val compare : osm_id -> osm_id -> int
    val sexp_of_t : osm_id -> Sexplib.Sexp.t
    val t_of_sexp : Sexplib.Sexp.t -> osm_id
  end

module OSMMap: Core.Std.Map.S

type osm_node = OSMNode of osm_node_t
 and osm_node_t = {
  id: osm_id;
  latitude: float;
  longitude: float;
  version: string;
  changeset: string;
  user: string;
  uid: string;
  visible: bool;
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
  visible: bool;
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

type osm_feature = OSMNode of osm_node_t |
                   OSMWay of osm_way_t |
                   OSMRelation of osm_relation_t

val empty_osm: osm

val add_to_osm: osm -> osm_feature -> osm
