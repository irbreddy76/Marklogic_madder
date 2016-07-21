module namespace s = "http://marklogic.com/search/similar";

import module namespace nm = "http://marklogic.com/name-matcher" at
  "/lib/name-matcher-lib.xqy";

declare variable $TRACE_LEVEL_TRACE as xs:string := "FIND-SIMILAR-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "FIND-SIMILAR-DETAIL";
declare variable $DEFAULT_LIMIT as xs:int := 10;

declare function s:find-similar($record as map:map, $uri as xs:string?, $limit as xs:string?) {
  let $header := map:get($record, "headers")
  let $recordType := map:get($header, "RecordType")
  let $max := 
    if(fn:empty($limit) or fn:string-length($limit) = 0) then $DEFAULT_LIMIT
    else xs:int($limit)
  let $_ := (
    fn:trace("find-similar -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- RecordType = " || $recordType, $TRACE_LEVEL_DETAIL)
  )
  return 
    if($recordType = "PersonParticipation") then
      s:similar-personparticipation($header, map:get($record, "content"), $uri, $max)
    else json:object()
};

declare function s:similar-personparticipation($header as map:map, $content as map:map, $uri as xs:string?,
  $limit as xs:int) {
  let $_ := fn:trace("similar-personparticipation -- CALLED", $TRACE_LEVEL_TRACE)
  let $score := map:get($params, "score")
  let $ssn := ()
  let $dob := ()
  let $firstNames := ()
  let $lastNames := ()
  let $_ := 
    for $record in json:array-values(map:get($content, "records"))
    let $person := map:get($record, "Person")
    return (
      let $date := map:get($person, "PersonBirthDate")
      return if(fn:empty($date)) then () else xdmp:set($dob, ($dob, xs:string($date))),
      for $id in json:array-values(map:get($person, "PersonSSNIdentification"))
      let $number := map:get($id, "IdentificationID")
      return if(fn:empty($number)) then () else xdmp:set($ssn, ($ssn, xs:string($number))),
      let $names := <body>{json:array-values(map:get($person, "PersonName"))}</body>
      return (
        xdmp:set($firstNames, ($firstNames, 
          fn:distinct-values(s:get-names($names/json:object/json:entry[./@key = "PersonGivenName"]/json:value)))
        ),
        xdmp:set($lastNames, ($lastNames, 
          fn:distinct-values(s:get-names($names/json:object/json:entry[./@key = "PersonSurName"]/json:value)))
        )
      )
    )
  let $params := map:map()
  let $_ := ( 
    s:add-parameter(fn:distinct-values($ssn), "ssn", $params),
    s:add-parameter(fn:distinct-values($dob), "dob", $params),
    s:add-parameter(fn:distinct-values($firstNames), "first", $params),
    s:add-parameter(fn:distinct-values($lastNames), "last", $params),
    map:put($params, "score", if(fn:empty($score)) then 24 else $score)
  )
  let $query := nm:get-query($params, map:map(), "xml")
  let $collection := "PersonParticipation"
  let $results :=  
    if(fn:empty($query)) then ()
    else 
      cts:search(fn:doc(), cts:and-query(($query, $collection,
        if(fn:string-length($uri) > 0) then cts:not-query(cts:document-query($uri)) else ())), 
        ("score-simple","unfiltered"))[1 to $limit] 
  let $_ := fn:trace(fn:concat(" -- Candidates found:", fn:string(cts:remainder($results[1]))), $TRACE_LEVEL_TRACE)
  let $array := json:array()
  let $_ :=
    for $candidate in $results
    let $candidate-entry := json:object()
    let $_ := (
      map:put($candidate-entry, "candidate", $candidate),
      map:put($candidate-entry, "uri", fn:document-uri($candidate))
    )
    return json:array-push($array, $candidate-entry)
  let $json := json:object()
  let $_ := (
    map:put($json, "results", $array),
    map:put($json, "count", json:array-size($array))
  )       
  return $json 
};

declare function s:add-parameter($param as xs:string*, $param-name as xs:string, $param-map as map:map) {
  if(fn:empty($param) or (fn:count($param) = 1 and fn:string-length(fn:normalize-space($param)) = 0)) then
    let $_ := fn:trace("add-parameter -- empty " || $param-name || " provided.", $TRACE_LEVEL_DETAIL)
    return ()
  else map:put($param-map, $param-name, $param)
};

declare function s:get-names($names as xs:string*) as xs:string* {
  for $name in $names
  let $text := fn:normalize-space($name)
  where fn:string-length($text) > 0
  return fn:lower-case($name)
};