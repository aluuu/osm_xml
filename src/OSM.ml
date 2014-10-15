open Core.Std

module StringMap = Map.Make (String)


type osm_id = OSMId of string

type osm_tags = string StringMap.t

module OSM_id = struct
  type t = osm_id
  let compare = fun (OSMId a) (OSMId b) -> String.compare a b
  let sexp_of_t = fun (OSMId a) -> String.sexp_of_t a
  let t_of_sexp = fun a -> OSMId (String.t_of_sexp a)
end

module OSMMap = Map.Make (OSMID_S)

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

type osm_relation = OSMRelation of osm_relation_t
 and osm_relation_t = {
  id: osm_id;
}

type osm = {
  nodes: osm_node;
  ways: osm_way;
  relations: osm_relation
}
