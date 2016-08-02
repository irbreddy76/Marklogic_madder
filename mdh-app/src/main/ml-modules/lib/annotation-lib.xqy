module namespace an = "http://www.dhr.state.md.us/datalake/annotation";

declare namespace err = "http://marklogic.com/xdmp/error";

declare variable $TRACE_LEVEL_TRACE as xs:string := "ANNOTATION-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "ANNOTATION-DETAIL";

declare function an:addAnnotation($params as map:map) {
  let $_ := (
    fn:trace("addAnnotation called", $TRACE_LEVEL_TRACE),
    for $key in map:keys($params)
    return 
      if($key = "properties") then (
        fn:trace(" -- param:properties:", $TRACE_LEVEL_DETAIL),
        for $property in map:get($params, "properties")
        return fn:trace("   -- property:" || map:get($property, "name") || "=" || map:get($property, "value"),
          $TRACE_LEVEL_DETAIL)
      )   
      else  
        fn:trace("  -- param:" || $key || "=" || map:get($params, $key), $TRACE_LEVEL_DETAIL)
  )
  for $uri in map:get($params, "uri")
  return
    try {
      an:annotateDocument($uri, $params)
    } catch($e) {
      let $json := json:object()
      let $message := fn:concat("Failed to annotate document at URI: ", $uri)
      let $_ := (
        xdmp:log($message, "error"),
        fn:trace($e, $TRACE_LEVEL_DETAIL),
        map:put($json, "error", $message),
        map:put($json, "reason", $e/err:message/fn:string(.))
      )
      return $json
    }
};

declare function an:annotateDocument($uri as xs:string, $params as map:map) {
  let $_ := (
    fn:trace("annotateDocument called", $TRACE_LEVEL_TRACE),
    fn:trace("document uri: " || $uri, $TRACE_LEVEL_DETAIL),
    for $key in map:keys($params)
    return
      if($key = "properties") then (
        fn:trace(" -- param:properties:", $TRACE_LEVEL_DETAIL),
        for $property in map:get($params, "properties")
        return fn:trace("   -- property:" || map:get($property, "name") || "=" || map:get($property, "value"),
          $TRACE_LEVEL_DETAIL)
      )   
      else  
        fn:trace("  -- param:" || $key || "=" || map:get($params, $key), $TRACE_LEVEL_DETAIL)
  )
  let $collections := xdmp:document-get-collections($uri)
  let $permissions := xdmp:document-get-permissions($uri)
  return 
    if(fn:doc-available($uri)) then (
      let $doc := xdmp:from-json(fn:doc($uri))
      let $identifiers := map:get(map:get($doc, "headers"), "SystemIdentifiers")
      let $content := map:get($doc, "content")
      let $annotation := an:createAnnotation($uri, $identifiers, $params)
      let $_ := (
        map:put($content, "annotation", $annotation),
        map:put($doc, "content", $content)
      )
      return $annotation
    ) else (
      let $json := json:object()
      let $message := fn:concat("Failed to annotate document at URI: ", $uri)
      let $reason := fn:concat("No document found at ", $uri)
      let $_ := (
        xdmp:log($reason, "warning"),
        map:put($json, "error", $message),
        map:put($json, "reason", $reason)
      )
      return $json        
    )
};

declare function an:createAnnotation($uri as xs:string, $identifiers, $params as map:map) {
  let $annotation := json:object()
  let $triples := json:array()
  let $headers := json:object()
  let $content := json:object()
  let $header-props := json:array()
  let $content-props := json:array()
  let $_ := (
    map:put($headers, "parentUri", $uri),
    map:put($headers, "identifiers", $identifiers),
    map:put($headers, "annotationDateTime", fn:current-dateTime()),
    map:put($headers, "annotationUser", 
      (map:get($params, "user"), xdmp:get-current-user())[1]),
    let $comments := map:get($params, "comments")
    return
      if(fn:empty($comments) or fn:string-length($comments) = 0) then ()
      else map:put($content, "comments", $comments),
    for $property in json:array-values(map:get($params, "properties"))
    let $header-prop := json:object()
    let $_ := map:put($header-prop, map:get($property, "name"), map:get($property, "value"))
    return (
      json:array-push($header-props, $header-prop),    
      json:array-push($content-props, $property)
    ),
    map:put($headers, "properties", $header-props),
    map:put($content, "properties", $content-props),  
    map:put($annotation, "triples", $triples),
    map:put($annotation, "headers", $headers),
    map:put($annotation, "content", $content)
  )
  let $_ := xdmp:document-insert(fn:concat($uri, "/annotations/annotation-", xdmp:hash64(xdmp:to-json-string($annotation)), ".json"), 
    xdmp:to-json($annotation), xdmp:document-get-permissions($uri), 
    (xdmp:document-get-collections($uri), "Annotation"))
  return $annotation
};

declare function an:getAnnotation($params as map:map) {
  let $_ := (
    fn:trace("getAnnotation called", $TRACE_LEVEL_TRACE),
    for $key in map:keys($params)
    return 
      if($key = "identifiers") then (
        fn:trace(" -- param:identifiers:", $TRACE_LEVEL_DETAIL),
        for $property in map:get($params, "identifiers")
        return fn:trace("   -- property:" || map:get($property, "name") || "=" || map:get($property, "value"),
          $TRACE_LEVEL_DETAIL)
      )   
      else  
        fn:trace("  -- param:" || $key || "=" || map:get($params, $key), $TRACE_LEVEL_DETAIL)
  )
  let $results :=
    cts:search(fn:doc(), cts:and-query((
      cts:collection-query("Annotation"), 
      if(map:contains($params, "user")) then 
        cts:json-property-value-query("annotationUser", map:get($params, "user"))
      else (),
      if(map:contains($params, "identifiers")) then
        cts:or-query((
          for $identifier in map:get($params, "identifiers")
          return cts:json-property-value-query(map:get($identifier, "name"),
            map:get($identifier, "value"))
        ))
      else (),
      if(map:contains($params, "before")) then
        cts:json-property-range-query(xs:QName("an:annotationDateTime"), "<=", xs:dateTime(map:get($params, "before")))
      else (),
      if(map:contains($params, "after")) then
        cts:json-property-range-query(xs:QName("an:annotationDateTime"), ">=", xs:dateTime(map:get($params, "after")))
      else ()
    )))
  let $_ := fn:trace(fn:concat(cts:remainder($results[1]), " annotations found"), $TRACE_LEVEL_TRACE)
  return $results
};
