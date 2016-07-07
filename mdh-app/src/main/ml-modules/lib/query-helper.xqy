module namespace qh = 'http://marklogic.com/query-helper';

import module namespace dict = 'http://marklogic.com/dictionary' at
  '/lib/dictionary-lib.xqy';

declare variable $qh:OPERATOR_EQUALS as xs:string := "=";
declare variable $qh:OPERATOR_LT as xs:string := "<";
declare variable $qh:OPERATOR_LTE as xs:string := "<=";
declare variable $qh:OPERATOR_GT as xs:string := ">";
declare variable $qh:OPERATOR_GTE as xs:string := ">=";
declare variable $qh:OUTPUT_JSON as xs:string := "json";
declare variable $qh:OUTPUT_XML as xs:string := "xml";
declare variable $TRACE_LEVEL_TRACE as xs:string := "QUERY-HELPER-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "QUERY-HELPER-DETAIL";
declare variable $qh:TYPE_NUMBER as xs:string := "number";
declare variable $qh:TYPE_STRING as xs:string := "string";
declare variable $qh:RANGE_TYPE_DATE as xs:string := "xs:date";
declare variable $qh:RANGE_TYPE_DATETIME as xs:string := "xs:dateTime";
declare variable $qh:RANGE_TYPE_TIME as xs:string := "xs:time";
declare variable $qh:ALG_TOKEN_MATCH as xs:string := "token-match";
declare variable $qh:ALG_DICTIONARY as xs:string := "dictionary";
declare variable $qh:ALG_TIME_WINDOW as xs:string := "time-window";
declare variable $qh:ALG_NONE as xs:string := "none";
declare variable $qh:DEFAULT_COLLATION as xs:string := "http://marklogic.com/collation/codepoint";

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
        else if($type = "xs:yearMonthDuration") then xs:yearMonthDuration($value)
        else if($type = "xs:dayTimeDuration") then xs:dayTimeDuration($value)
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
        else if($algorithm = $qh:ALG_TIME_WINDOW) then
          let $duration := qh:read-map-value($config, $defaults/param/time-range, $defaults/time-window)
          let $weight := qh:read-map-value($config, $defaults/param/weight, $defaults/weight)
          let $date-value := 
            if($defaults/type = $qh:RANGE_TYPE_DATE) then xs:date($term)
            else if($defaults/type = $qh:RANGE_TYPE_DATETIME) then xs:dateTime($term)
            else xs:time($term)
          let $lower-bound := 
            qh:range-q($defaults/property, $date-value - $duration, $qh:OPERATOR_GTE, 
              (), $weight, $output, $type, $defaults/collation)
          let $upper-bound :=
            qh:range-q($defaults/property, $date-value + $duration, $qh:OPERATOR_LT, 
              (), $weight, $output, $type, $defaults/collation)
          let $query := 
            if($output = $qh:OUTPUT_JSON) then
              let $json := json:object()
              let $and-query := json:object()
              let $_ := (
                map:put($and-query, "queries", qh:build-array(($lower-bound, $upper-bound))),
                map:put($json, "and-query", $and-query)
              )
              return $json
            else cts:and-query(($lower-bound, $upper-bound))
          let $_ := fn:trace(fn:concat(" -- query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
            else xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
          return $query
        else  (: Default search is to just try to match on the term :)
          let $weight := qh:read-map-value($config, $defaults/param/weight, $defaults/weight)
          let $operator := $defaults/operator
          for $property in $defaults/property
          let $query := 
            if(fn:empty($operator)) then qh:value-q($property, $term, (), $weight, $output, $type)
            else 
              let $value := 
                if($defaults/type = $qh:RANGE_TYPE_DATE) then xs:date($term)
                else if($defaults/type = $qh:RANGE_TYPE_DATETIME) then xs:dateTime($term)
                else xs:string($term)
              return
                qh:range-q($defaults/property, $value, $operator, 
                  (), $weight, $output, $type, $defaults/collation)
          let $_ := fn:trace(fn:concat(" -- query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
            else xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
          return $query
};

declare function qh:get-response-object($exact-queries as item()*, $or-queries as item()*, $output as xs:string) {
  if($output = $qh:OUTPUT_JSON) then 
    let $or-query := 
      if(fn:empty($or-queries)) then ()
      else
        let $root := json:object()
        let $children := 
          let $node := json:object()
          let $_ := map:put($node, "queries", qh:build-array($or-queries))
          return $node
       let $_ := map:put($root, "or-query", $children)
       return $root
    let $and-query :=
      if(fn:empty($exact-queries)) then ($or-query, json:object())[1]
      else if(fn:count(($exact-queries, $or-query)) = 1) then ($exact-queries, $or-query)
      else 
        let $root := json:object()
        let $children :=
          let $node := json:object()
          let $_ := map:put($node, "queries", ($exact-queries, $or-query))
          return $node
        let $_ := map:put($root, "and-query", $children)
        return $root
    return $and-query
  else if(fn:empty(($exact-queries, $or-queries))) then ()
  else
    let $or-query := 
      if(fn:empty($or-queries)) then ()
      else cts:or-query($or-queries)
    return
      if(fn:empty($exact-queries)) then $or-query
      else cts:and-query(($exact-queries, $or-query))
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

declare function qh:build-array($items as item()*) {
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
declare function qh:range-q($name as xs:string, $term as xs:anyAtomicType, $operator as xs:string, 
  $options as xs:string*, $weight as xs:double, $output as xs:string, $type as xs:string, 
  $collation as xs:string?) {
    let $operator-text := 
      if($operator = '>=') then "GE"
      else if($operator = '<=') then "LE"
      else if($operator = '>') then "GT"
      else if($operator = '<') then "LT"
      else "EQ"
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
      if($output = $qh:OUTPUT_JSON) then
        let $json := json:object()
        let $range-query := json:object()
        let $_ := (
          if($type = "xs:string") then
            map:put($range-query, "collation", ($collation, $qh:DEFAULT_COLLATION)[1])
          else (),
          map:put($range-query, "type", $type),
          map:put($range-query, "json-property", $name),
          map:put($range-query, "value", $term),
          if(fn:empty($options)) then ()
          else map:put($range-query, "range-option", qh:build-array($options)),
          map:put($range-query, "range-operator", $operator-text),
          (:map:put($range-query, "weight", $weight div 8),:)
          map:put($json, "range-query", $range-query)       
        )
      return $json 
      else 
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
