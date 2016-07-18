xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

declare option xdmp:mapping "false";

(:~
 : Writer Plugin
 :
 : @param $id       - the identifier returned by the collector
 : @param $envelope - the final envelope
 : @param $options  - a map containing options. Options are sent from Java
 :
 : @return - nothing
 :)
declare function plugin:write(
  $id as xs:string,
  $envelope as node(),
  $options as map:map) as empty-sequence()
{
  let $new-images := json:array-values(
    map:get(
      map:get(xdmp:from-json($envelope), "content"), "images")
  )
  for $record in cts:search(fn:doc(), cts:and-query((
    cts:collection-query(("Person", "PersonParticipation")),
    cts:collection-query("CHESSIE"),
    cts:json-property-value-query("chessieId", ($id, xs:int($id)))
  )))
  let $json := xdmp:from-json($record)
  let $content := map:get($json, "content")
  let $person := 
    if("Person" = map:keys($content)) then map:get($content, "Person")
    else $content
  let $images := 
    if("images" = map:keys($person)) then map:get($person, "images")
    else json:array()
  let $_ := for $image in $new-images return json:array-push($images, $image)
  let $_ := map:put($person, "images", $images)
  let $_ := 
    if("Person" = map:keys($content)) then map:put($content, "Person", $person)
    else ()
  let $_ := map:put($json, "content", $content)
  let $uri := fn:document-uri($record)
  return xdmp:document-insert($uri, xdmp:to-json($json),
    xdmp:document-get-permissions($uri), 
    xdmp:document-get-collections($uri))
};
