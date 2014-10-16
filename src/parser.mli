val parse_file: string -> Types.osm

val parse_node: Xmlm.input -> Types.osm_feature option

val parse_way: Xmlm.input -> Types.osm_feature option

val parse_relation: Xmlm.input -> Types.osm_feature option

val parse_tags: Xmlm.input -> Types.osm_tags option
