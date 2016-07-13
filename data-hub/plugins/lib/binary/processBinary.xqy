module namespace bin = "http://marklogic.com/process-binary";

declare namespace html = "http://www.w3.org/1999/xhtml";

declare function bin:processBinary(
  $uri as xs:string, 
  $binary-node as node(), 
  $data-format as xs:string) 
  as item() {
  let $_ := xdmp:document-insert($uri, $binary-node, xdmp:default-collections())
  let $metadata := xdmp:document-filter($binary-node)
  return 
    if($data-format = "application/json") then
      let $json := json:object()
      let $_ := (
        for $tag in $metadata/html:html/html:head/html:meta
        return map:put($json, $tag/@name/fn:string(.), $tag/@content/fn:data(.)),
        map:put($json, "original", $uri)
      )
      return xdmp:to-json($json)
    else
      <metadata>
      {
        for $tag in $metadata/html:html/html:head/html:meta
        return element{ xs:QName($tag/@name/fn:string(.)) } { $tag/@content/fn:string(.) },
        element { xs:QName("original") } { $uri }
      }
      </metadata>
};
