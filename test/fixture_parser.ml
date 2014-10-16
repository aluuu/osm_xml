let node_example =
  "<node id=\"25496583\" lat=\"51.5173639\" lon=\"-0.140043\" version=\"1\" changeset=\"203496\" user=\"80n\" uid=\"1238\" visible=\"true\" timestamp=\"2007-01-28T11:40:26Z\"><tag k=\"highway\" v=\"traffic_signals\"/></node>"

let way_example = "
<way id=\"5090250\" visible=\"true\" timestamp=\"2009-01-19T19:07:25Z\" version=\"8\" changeset=\"816806\" user=\"Blumpsy\" uid=\"64226\">
  <nd ref=\"822403\"/>
  <nd ref=\"21533912\"/>
  <nd ref=\"821601\"/>
  <nd ref=\"21533910\"/>
  <nd ref=\"135791608\"/>
  <nd ref=\"333725784\"/>
  <nd ref=\"333725781\"/>
  <nd ref=\"333725774\"/>
  <nd ref=\"333725776\"/>
  <nd ref=\"823771\"/>
  <tag k=\"highway\" v=\"residential\"/>
  <tag k=\"name\" v=\"Clipstone Street\"/>
  <tag k=\"oneway\" v=\"yes\"/>
</way>"

let relation_example = "
<relation id=\"3961709\" version=\"1\" timestamp=\"2014-08-15T07:53:13Z\" uid=\"395071\" user=\"Xmypblu\" changeset=\"24761364\">
    <member type=\"way\" ref=\"297850757\" role=\"outer\"/>
    <member type=\"way\" ref=\"282442652\" role=\"outer\"/>
    <member type=\"way\" ref=\"282442655\" role=\"outer\"/>
    <member type=\"way\" ref=\"282442656\" role=\"outer\"/>
    <member type=\"way\" ref=\"282442686\" role=\"outer\"/>
    <member type=\"way\" ref=\"297850792\" role=\"outer\"/>
    <member type=\"way\" ref=\"297850798\" role=\"outer\"/>
    <member type=\"node\" ref=\"452094096\" role=\"admin_centre\"/>
    <tag k=\"admin_level\" v=\"8\"/>
    <tag k=\"boundary\" v=\"administrative\"/>
    <tag k=\"name\" v=\"Ядринский сельсовет\"/>
    <tag k=\"type\" v=\"boundary\"/>
  </relation>
"
