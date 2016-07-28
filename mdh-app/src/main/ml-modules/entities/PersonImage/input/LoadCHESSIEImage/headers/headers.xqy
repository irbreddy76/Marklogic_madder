xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

declare namespace envelope = "http://marklogic.com/data-hub/envelope";

declare option xdmp:mapping "false";

(:~
 : Create Headers Plugin
 :
 : @param $id      - the identifier returned by the collector
 : @param $content - the output of your content plugin
 : @param $options - a map containing options. Options are sent from Java
 :
 : @return - zero or more header nodes
 :)
declare function plugin:create-headers(
  $id as xs:string,
  $content as node()?,
  $options as map:map) as node()*
{
  let $filename := fn:tokenize($id, "/")[last()]
  let $json := json:object()
  let $_ := (
    map:put($json, "chessieId", fn:tokenize($filename, "_")[1]),
    map:put($json, "RecordType", "PersonImage")
  )
  return xdmp:to-json($json)
};
