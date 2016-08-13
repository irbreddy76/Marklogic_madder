module namespace pm = 'http://marklogic.com/person-merge';

declare namespace sec = "http://marklogic.com/xdmp/security";

declare variable $TRACE_LEVEL_TRACE as xs:string := "PERSON-MERGE-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "PERSON-MERGE-DETAIL";

declare function pm:merge($primary-uri as xs:string, $secondary-uri as xs:string, $options as item()?) {
  let $_ := (
    fn:trace("merge -- called", $TRACE_LEVEL_TRACE),
    fn:trace(" -- primary-uri: " || $primary-uri, $TRACE_LEVEL_DETAIL),
    fn:trace(" -- secondary-uri: " || $secondary-uri, $TRACE_LEVEL_DETAIL)
  )  
  let $merged-doc := json:object()
  let $permissions := pm:get-permissions($primary-uri, $secondary-uri)
  let $collections := fn:distinct-values((xdmp:document-get-collections($primary-uri),
    xdmp:document-get-collections($secondary-uri)))
  let $primary-doc := xdmp:from-json(fn:doc($primary-uri))
  let $primary-header := map:get($primary-doc, "headers")
  let $secondary-doc := xdmp:from-json(fn:doc($secondary-uri))
  let $secondary-header := map:get($secondary-doc, "headers")
  let $merge-log := pm:build-log($primary-uri, $primary-header, 
    $secondary-uri, $secondary-header, $options, $permissions)
  let $triples := json:to-array((
    json:array-values(map:get($primary-doc, "triples")),
    json:array-values(map:get($secondary-doc, "triples"))
  ))
  let $primary-content := map:get($primary-doc, "content")
  let $secondary-content := map:get($secondary-doc, "content")
  let $records := json:to-array((
    json:array-values(map:get($primary-content, "records")),
    json:array-values(map:get($secondary-content, "records"))
  ))
  let $_ := (
    map:put($merged-doc, "triples", $triples),
    map:put($merged-doc, "content", 
      let $content := json:object()
      let $_ := map:put($content, "records", $records)
      return $content),
    map:put($merged-doc, "headers", 
      pm:merge-headers($primary-header, $secondary-header, $options))
  )
  let $uri := "/person/merged/" || xdmp:hash64(xdmp:to-json-string($merged-doc)) || ".json"
  return (
    xdmp:document-add-collections($primary-uri, "deleted"),
    xdmp:document-add-collections($secondary-uri, "deleted"),
    xdmp:document-insert($uri, xdmp:to-json($merged-doc), $permissions/*,
      $collections),
    $uri
  )
};

declare function pm:build-log($primary-uri as xs:string, $primary-header as map:map, 
  $secondary-uri as xs:string, $secondary-header as map:map, $options as item()?,
  $permissions as element(permissions)) {
  let $log := json:object()
  let $primary-record := json:object()
  let $secondary-record := json:object()
  let $_ := (
    map:put($primary-record, "uri", $primary-uri),
    map:put($primary-record, "identifiers", map:get($primary-header, "SystemIdentifiers")),
    map:put($secondary-record, "uri", $secondary-uri),
    map:put($secondary-record, "identifiers", map:get($secondary-header, "SystemIdentifiers")),
    if(fn:empty($options)) then () else map:put($log, "options", $options),
    map:put($log, "primary", $primary-record),
    map:put($log, "secondary", $secondary-record),
    map:put($log, "mergedOn", fn:current-dateTime()),
    map:put($log, "mergedBy", xdmp:get-current-user()),
    map:put($log, "mergedDocs", json:array())    
  )
  let $mergeDb := fn:replace(xdmp:database-name(xdmp:database()), "FINAL", "AUDIT")
  return xdmp:invoke("/lib/merge-log.xqy", (xs:QName("merge-log"), $log, 
    xs:QName("permissions"), $permissions), 
    <options xmlns="xdmp:eval">
      <database>{xdmp:database($mergeDb)}</database>
    </options>
  )
};

declare function pm:get-permissions($primary as xs:string, $secondary as xs:string) as element(permissions) {
  let $permissions := <permissions>{
    (xdmp:document-get-permissions($primary), xdmp:document-get-permissions($secondary))}</permissions>
  return
    <permissions>
    {
      for $capability in ("read", "insert", "update", "execute")
      for $role in fn:distinct-values($permissions/sec:permission[./sec:capability = $capability]/sec:role-id)
      return xdmp:permission($role, $capability)
    }
    </permissions>
};

declare function pm:merge-headers($primary-header as map:map, $secondary-header as map:map, 
  $options as item()?) {
  let $header := json:object()
  let $_ := (
     map:put($header, "RecordType", "MasterPerson"),
     map:put($header, "SystemIdentifiers", 
       pm:merge-identifiers(
         map:get($primary-header, "SystemIdentifiers"),
         map:get($secondary-header, "SystemIdentifiers"),
         $options
       )
     ),
     map:put($header, "ParticipationIdentifiers", 
       pm:merge-identifiers(
         map:get($primary-header, "ParticipationIdentifiers"),
         map:get($secondary-header, "ParticipationIdentifiers"),
         $options
       )
     ),
     map:put($header, "Addresses", 
       pm:merge-array(
         map:get($primary-header, "Addresses"),
         map:get($secondary-header, "Addresses"),
         $options
       )
     ),
     map:put($header, "PersonPrimaryName", 
       pm:merge-property(
         map:get($primary-header, "PersonPrimaryName"),
         map:get($secondary-header, "PersonPrimaryName"),
         $options
       )
     ),
     map:put($header, "SSNIdentificationId", 
       pm:merge-value(
         pm:read-value($primary-header, "SSNIdentificationId"),
         pm:read-value($secondary-header, "SSNIdentificationId"),
         $options
       )
     )
  )
  return $header
};

declare function pm:merge-identifiers($primary, $secondary, $options as item()?) {
  let $identifiers := map:map()
  let $_ :=
    for $identifier in (json:array-values($primary), json:array-values($secondary))
    let $key := map:keys($identifier)[1]
    return map:put($identifiers, $key, (map:get($identifiers, $key), map:get($identifier, $key)))
  let $array := json:array()
  let $_ := 
    for $identifier in map:keys($identifiers)
    for $value in fn:distinct-values(map:get($identifiers, $identifier))
    let $json := json:object()
    let $_ := map:put($json, $identifier, $value)
    return json:array-push($array, $json)
  return $array
};

declare function pm:merge-array($primary, $secondary, $options as item()?) {
  json:to-array((
    json:array-values($primary), json:array-values($secondary)
  ))
};

declare function pm:merge-property($primary as map:map, $secondary as map:map, $options as item()?) {
  let $json := json:object()
  let $_ := 
    for $key in fn:distinct-values((map:keys($primary), map:keys($secondary)))
    return map:put($json, $key, (pm:read-value($primary, $key), pm:read-value($secondary, $key))[1])
  return $json
}; 

declare function pm:merge-value($primary as xs:anyAtomicType?, $secondary as xs:anyAtomicType?, $options as item()?) {
  ($primary, $secondary)[1]
};

declare function pm:read-value($json as map:map, $property as xs:string) {
  let $value := map:get($json, $property)
  return
    if(fn:string-length(fn:normalize-space(xs:string($value))) > 0) then $value else ()
};