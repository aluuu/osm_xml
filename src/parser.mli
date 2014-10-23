type xml_tree = XMLElement of Xmlm.tag * xml_tree list | XMLData of string

val input_tree: Xmlm.input -> xml_tree

val find_attr: Xmlm.attribute list -> string -> string option

val required_attr: Xmlm.attribute list -> string -> string

val parse_tags: xml_tree list -> Types.osm_tags

val parse_node: Xmlm.input -> Types.osm_feature option

val parse_way: Xmlm.input -> Types.osm_feature option

val parse_relation: Xmlm.input -> Types.osm_feature option

val parse_feature: Xmlm.input -> Types.osm_feature option

type parse_options = ParseOptions of parse_options_t
 and parse_options_t = {
   parse_nodes: bool;
   parse_ways: bool;
   parse_relations: bool
 }

val default_parse_opts: parse_options

val parse_file: string -> Types.osm
