open Core.Std
open OSM
open Types
open OUnit
open Fixture_parser

let create_xml_input str =
  let xml_input = Xmlm.make_input (`String (0, str)) in
  (* first signal is DTD, so ignore it *)
  let _ = Xmlm.input xml_input in
  xml_input

let test_parse_node () =
  let xml_input = create_xml_input node_example in
  let result = Parser.parse_node xml_input in
  match result with
  | Some (OSMNode node) ->
     assert_equal node.id (OSMId "25496583");
     assert_equal node.user "80n";
     assert_equal node.visible true;
     assert_equal node.latitude 51.5173639;
     assert_equal node.longitude (-. 0.140043);
     assert_equal (find_tag node.tags "highway") (Some "traffic_signals")
  | Some _ ->
     failwith "Wrong parser was given for this fixture.
               Maybe you're using `parse_way` or `parse_relation`."
  | None ->
     failwith "Wrong fixture was given to `parse_node`."

let test_parse_way () =
  let xml_input = create_xml_input way_example in
  let result = Parser.parse_way xml_input in
  match result with
  | Some (OSMWay way) ->
     assert_equal way.id (OSMId "5090250");
     assert_equal way.user "Blumpsy";
     assert_equal way.visible true;
     assert_equal (find_tag way.tags "highway") (Some "residential");
     assert_equal (find_tag way.tags "oneway") (Some "yes");
     assert_equal (List.length way.nodes) 10;
     assert_equal (List.hd way.nodes) (Some (OSMId "822403"));
     assert_equal (List.last way.nodes) (Some (OSMId "823771"))
  | Some _ ->
     failwith "Wrong parser was given for this fixture.
               Maybe you're using `parse_node` or `parse_relation`."
  | None ->
     failwith "Wrong fixture was given to `parse_way`."
  ()

let test_parse_relation () =
  let xml_input = create_xml_input relation_example in
  let Some (OSMRelation relation) = Parser.parse_relation xml_input in
  ()

let test_parse_file () =
  let _ = Parser.parse_file "./samples/test.xml" in
  ()

let test =
  "Parser" >::: [
    "parse node" >:: test_parse_node;
    "parse way" >:: test_parse_way;
    "parse relation" >:: test_parse_relation;
    "parse file" >:: test_parse_file;
  ];;
