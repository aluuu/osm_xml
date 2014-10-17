type xml_tree = XMLElement of Xmlm.tag * xml_tree list | XMLData of string

val input_tree: Xmlm.input -> xml_tree

val find_attr: Xmlm.attribute list -> string -> string option

val required_attr: Xmlm.attribute list -> string -> string

val parse_tags: xml_tree list -> Types.osm_tags

val parse_node: Xmlm.input -> Types.osm_feature option

val parse_way: Xmlm.input -> Types.osm_feature option

val parse_relation: Xmlm.input -> Types.osm_feature option

val handle_xml_element: Xmlm.input -> Types.osm_feature option

val parse_file: string -> Types.osm
