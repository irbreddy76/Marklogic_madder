xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

declare option xdmp:mapping "false";

(:~
 : Collect IDs plugin
 :
 : @param $options - a map containing options. Options are sent from Java
 :
 : @return - a sequence of ids or uris
 :)
declare function plugin:collect(
  $options as map:map) as xs:string*
{
  for $value in cts:element-values(xs:QName("chessieId"), (), (),
    cts:and-not-query(
      cts:collection-query("PersonImage"),
      cts:collection-query("processed")
    )
  )
  let $_ := xdmp:log("collector - " || xs:string($value))
  return xs:string($value)
};

