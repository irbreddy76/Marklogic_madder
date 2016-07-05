module namespace qh = 'http://marklogic.com/query-helper';

import module namespace dict = 'http://marklogic.com/dictionary' at
  '/lib/dictionary-lib.xqy';
  
declare variable $qh:OUTPUT_JSON as xs:string := "json";
declare variable $qh:OUTPUT_XML as xs:string := "xml";
declare variable $TRACE_LEVEL_TRACE as xs:string := "QUERY-HELPER-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "QUERY-HELPER-DETAIL";
declare variable $qh:TYPE_NUMBER as xs:string := "number";
declare variable $qh:TYPE_STRING as xs:string := "string";
declare variable $qh:ALG_TOKEN_MATCH as xs:string := "token-match";
declare variable $qh:ALG_DICTIONARY as xs:string := "dictionary";
declare variable $qh:ALG_NONE as xs:string := "none";

(: Helper Functions :)
declare function qh:is-string-empty($string as xs:string*) as xs:boolean { 
  if(empty($string) or $string = "") then fn:true() else fn:false()
};

(: Attempt to read a map value.  If the specified key does not exist,
 : replace it with the specified default value.  Cast the return value
 : as the simple type identified in the default value :)
declare function qh:read-map-value($map as map:map, $key as xs:string, 
  $default as element()) as xs:anyAtomicType? {
  let $value := (map:get($map, $key), $default)[1]
  return
    if(fn:empty($value)) then ()
    else  
      let $type := $default/@type
      return
        if($type = "xs:date") then xs:date($value)
        else if($type = "xs:dateTime") then xs:dateTime($value)
        else if($type = "xs:time") then xs:time($value)
        else if($type = "xs:duration") then xs:duration($value)
        else if($type = "xs:float") then xs:float($value)
        else if($type = "xs:double") then xs:double($value)
        else if($type = "xs:decimal") then xs:decimal($value)
        else if($type = "xs:string") then xs:string($value)
        else if($type = "xs:boolean") then xs:boolean($value)
        else $value
};

declare function qh:build-query($term as xs:string*, $config as map:map, $defaults as element(),
  $output as xs:string) {
  let $_ := (
    fn:trace("build-query -- called", $TRACE_LEVEL_TRACE),
    fn:trace(" -- defaults:" || xdmp:quote($defaults), $TRACE_LEVEL_DETAIL),
    fn:trace(" -- output:" || $output, $TRACE_LEVEL_DETAIL)
  )
  return
    if(qh:is-string-empty($term)) then ()
    else
      let $type := $defaults/type
      let $algorithm := qh:read-map-value($config, $defaults/param/algorithm, $defaults/algorithm)
      return
        if($algorithm = $qh:ALG_TOKEN_MATCH) then
          (: tokenize the term.  each matching part contributes to the score :)
          let $separator := 
          if(fn:string-length($defaults/separator) > 0) then $defaults/separator 
          else " "
        let $parts := 
          for $part in fn:tokenize($term, $separator)
          where fn:string-length($part) > 2
          return $part
        let $weight := qh:read-map-value($config, $defaults/param/weight, $defaults/token-weight)
        for $property in $defaults/property
        let $query := qh:word-q($property, $parts, (), $weight, $output)
        let $_ := fn:trace(fn:concat(" -- query:",  
          if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
          else xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
        return $query
      else if($algorithm = $qh:ALG_DICTIONARY) then
        (: Get similar terms from a dictionary.  Matches to the primary term are
           assigned the full weight while matches to similar terms are adjusted by a multiplier :)
        let $similar := 
          if($type = $qh:TYPE_NUMBER) then 
            dict:get-similar-numbers($term, $defaults/dictionary, 
              qh:read-map-value($config, $defaults/param/edit-distance, $defaults/edit-distance),
              qh:read-map-value($config, $defaults/param/word-distance, $defaults/word-distance),
              qh:read-map-value($config, $defaults/param/similar-limit, $defaults/similar-limit))
          else
            dict:get-similar-words($term, $defaults/dictionary, 
              qh:read-map-value($config, $defaults/param/word-distance, $defaults/word-distance),
              qh:read-map-value($config, $defaults/param/similar-limit, $defaults/similar-limit))
        let $weight := qh:read-map-value($config, $defaults/param/weight, $defaults/weight)
        for $property in $defaults/property
        let $query := qh:value-q($property, $term, (), $weight, $output, $type)
        let $similar-query := 
          if(fn:empty($similar)) then ()
          else qh:value-q($property, $similar, (), $weight *
            qh:read-map-value($config, $defaults/param/weight-multiplier, $defaults/multiplier),
            $output, $type
          )
        let $_ := (
          fn:trace(fn:concat(" -- query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
            else xdmp:quote($query)), $TRACE_LEVEL_DETAIL),
          fn:trace(fn:concat(" -- similar-query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($similar-query)
            else xdmp:quote($similar-query)), $TRACE_LEVEL_DETAIL)
        )
        return ($query, $similar-query)
      else  (: Default search is to just try to match on the term :)
        let $weight := qh:read-map-value($config, $defaults/param/weight, $defaults/weight)
        for $property in $defaults/property
        let $query := qh:value-q($property, $term, (), $weight, $output, $type)
        let $_ := fn:trace(fn:concat(" -- query:", 
          if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
          else xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
        return $query
};

declare function qh:get-response-object($queries as item()*, $output as xs:string) {
  if($output = $qh:OUTPUT_JSON) then 
    let $json := json:object()
    let $array :=
      let $target := json:array()
      let $_ := 
        for $query in $queries return json:array-push($target, $query)
        return $target
      let $queryobject :=
      let $object := json:object()
      let $_ := map:put($object, "queries", $array)
      return $object
    let $_ := 
      if(fn:count($queries) > 0) then
        map:put($json, "or-query", $queryobject) 
      else ()
    return $json
  else if(fn:count($queries) > 0) then cts:or-query($queries)
  else ()
};

(: 
 : score-simple gives 8pts per matching term and multiplies the results by 256 (MarkLogic documentation)
 : this reduces the magnitude of the score
 :)
declare function qh:score($item) {
  cts:score($item) div 256  
};

(: Query Builders :)
(: 
 : Build a basic JSON Property query with the specified search options.
 : weight is divided by 8 to reset the simple scoring to 1 pt per match 
 : @params name - the name of the property
 : @params term - the term value(s) to match
 : @params options - any search options for this term
 : @params weight - weight to assign matches for these terms
 : @params output - JSON or cts:query
 :)
declare function qh:value-q($name as xs:string, $term as xs:string*, $options as xs:string*,
  $weight as xs:double, $output as xs:string?, $type as xs:string) {
    if($output = $qh:OUTPUT_JSON) then 
      let $json := json:object()
      let $value-query := json:object()
      let $_ := (
        map:put($value-query, "type", $type),
        map:put($value-query, "json-property", $name),
        map:put($value-query, "text", qh:build-array($term)),
        if(fn:empty($options)) then ()
        else map:put($value-query, "term-option", qh:build-array($options)),
        map:put($value-query, "weight", $weight div 8),
        map:put($json, "value-query", $value-query)       
      )
      return $json
    else cts:json-property-value-query($name, $term, $options, $weight div 8)
};

declare function qh:build-array($items as xs:string*) {
  let $array := json:array()
  let $_ := 
    for $item in $items
    return json:array-push($array, $item)
  return $array
};

(: 
 : Build a basic JSON Property range query with the specified search options.
 : weight is divided by 8 to reset the simple scoring to 1 pt per match 
 : @params name - the name of the property
 : @params term - the term value(s) to match
 : @params operator - the comparison operator
 : @params options - any search options for this term
 : @params weight - weight to assign matches for these terms
 :)
declare function qh:range-q($name as xs:string, $term as xs:anyAtomicType*, $operator as xs:string, 
  $options as xs:string*, $weight as xs:double) as cts:query? { 
    let $score-option-found := false()
    let $consolidated-options := (
      for $option in $options
      let $_ := 
        if(fn:starts-with($option, "score-function")) 
        then xdmp:set($score-option-found, true()) else ()
      return $option,
      if(not($score-option-found)) then "score-function=linear" else ()
    )
    return
      cts:json-property-range-query($name, $operator, $term, $consolidated-options, $weight div 8)
};

(: 
 : Build a basic JSON Property word query with the specified search options.
 : weight is divided by 8 to reset the simple scoring to 1 pt per match 
 : @params name - the name of the property
 : @params term - the term value(s) to match
 : @params options - any search options for this term
 : @params weight - weight to assign matches for these terms
 : @params output - output type, JSON or cts query
 :)
declare function qh:word-q($name as xs:string, $term as xs:string*, $options as xs:string*, 
  $weight as xs:double, $output as xs:string) {
  if($output = $OUTPUT_JSON) then 
    let $json := json:object()
    let $word-query := json:object()
    let $_ := (
      map:put($word-query, "json-property", $name),
      map:put($word-query, "text", qh:build-array($term)),
      if(fn:empty($options)) then ()
      else map:put($word-query, "term-option", qh:build-array($options)),
      map:put($word-query, "weight", $weight div 8),
      map:put($json, "word-query", $word-query)       
    )
    return $json
  else cts:json-property-word-query($name, $term, $options, $weight div 8)
};