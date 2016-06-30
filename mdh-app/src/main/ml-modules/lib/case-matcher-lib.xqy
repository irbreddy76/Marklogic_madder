module namespace cm = 'http://marklogic.com/case-matcher';

import module namespace qh = 'http://marklogic.com/query-helper' at
  '/lib/query-helper.xqy';
import module namespace dict = 'http://marklogic.com/dictionary' at
  '/lib/dictionary-lib.xqy';

(: Enumerated values :)
declare variable $OPERATOR_EQUALS as xs:string := "=";
declare variable $OPERATOR_LESS_THAN as xs:string := "<";
declare variable $OPERATOR_LESS_THAN_OR_EQUAL as xs:string := "<=";
declare variable $OPERATOR_GREATER_THAN as xs:string := ">";
declare variable $OPERATOR_GREATER_THAN_OR_EQUAL as xs:string := ">=";
declare variable $TRACE_LEVEL_TRACE as xs:string := "NAME-MATCH-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "NAME-MATCH-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "NAME-MATCH-FINE";
declare variable $TYPE_NUMBER as xs:string := "number";
declare variable $TYPE_WORD as xs:string := "word";
declare variable $ALG_TOKEN_MATCH as xs:string := "token-match";
declare variable $ALG_DICTIONARY as xs:string := "dictionary";
declare variable $ALG_NONE as xs:string := "none";
declare variable $CONFIG := 
<configuration>
  <status>
    <!-- Property name used for JSON queries -->
    <property>status</property>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>status</key>
      <algorithm>status_algorithm</algorithm>
      <weight>status_wt</weight>
      <word-distance>status_word_distance</word-distance>
      <weight-multiplier>status_mult</weight-multiplier>
      <similar-limit>status_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">12</weight>
    <token-weight type="xs:double">8</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$ALG_NONE}</algorithm>
  </status>
  <cd>
    <!-- Property name used for JSON queries -->
    <property>CloseDate</property>
    <separator>-</separator>
    <!--<dictionary>/dictionaries/birth-date.xml</dictionary>-->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>cd</key>
      <algorithm>cd_algorithm</algorithm>
      <weight>cd_wt</weight>
      <edit-distance>cd_edit_distance</edit-distance>
      <word-distance>cd_word_distance</word-distance>
      <weight-multiplier>cd_mult</weight-multiplier>
      <similar-limit>cd_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">8</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$ALG_TOKEN_MATCH}</algorithm>
  </cd>
  <ccode>
    <!-- Property name used for JSON queries -->
    <property>CloseCode</property>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>ccode</key>
      <algorithm>ccode_algorithm</algorithm>
      <weight>ccode_wt</weight>
      <word-distance>ccode_word_distance</word-distance>
      <weight-multiplier>ccode_mult</weight-multiplier>
      <similar-limit>ccode_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">12</weight>
    <token-weight type="xs:double">8</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$ALG_NONE}</algorithm>
  </ccode>
  <ctype>
    <!-- Property name used for JSON queries -->
    <property>CaseType</property>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>ctype</key>
      <algorithm>ctype_algorithm</algorithm>
      <weight>ctype_wt</weight>
      <word-distance>ctype_word_distance</word-distance>
      <weight-multiplier>ctype_mult</weight-multiplier>
      <similar-limit>ctype_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">18</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$ALG_NONE}</algorithm>
  </ctype>
  <ppn>
    <!-- Property name used for JSON queries -->
    <property>ParticipationProgramName</property>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>ppn</key>
      <algorithm>ppn_algorithm</algorithm>
      <weight>ppn_wt</weight>
      <word-distance>ppn_word_distance</word-distance>
      <weight-multiplier>ppn_mult</weight-multiplier>
      <similar-limit>ppn_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">18</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$ALG_NONE}</algorithm>
  </ppn>
  <config>
    <result-limit>
      <key>limit</key>
      <value type="xs:integer">100</value>
    </result-limit>
    <min-score>
      <key>score</key>
      <value type="xs:double">0</value>
    </min-score>
    <sort>
      <key>sort</key>
      <value type="xs:string">wsd</value>
    </sort>
  </config>
</configuration>;

(: Helper Functions :)
declare function cm:is-string-empty($string as xs:string*) as xs:boolean { 
  if(empty($string) or $string = "") then fn:true() else fn:false()
};

(: Attempt to read a map value.  If the specified key does not exist,
 : replace it with the specified default value.  Cast the return value
 : as the simple type identified in the default value :)
declare function cm:read-map-value($map as map:map, $key as xs:string, 
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

declare function cm:get-query($params as map:map, $config as map:map,  $output as xs:string) { 
  let $_ := (
    fn:trace("GET-QUERY -- CALLED", $TRACE_LEVEL_TRACE),
    for $key in map:keys($params)
    return
      fn:trace(" -- params.key:" || $key || "=" || map:get($params, $key), $TRACE_LEVEL_DETAIL),
    for $key in map:keys($config)
    return
      fn:trace(" -- config.key:" || $key || "=" || map:get($config, $key), $TRACE_LEVEL_DETAIL),
    fn:trace(" -- output:" || $output, $TRACE_LEVEL_DETAIL)  
  )
  let $queries := (
    cm:build-query(fn:lower-case(map:get($params, $CONFIG/status/param/key)), $config, $CONFIG/status, $output, $TYPE_WORD),
    cm:build-query(map:get($params, $CONFIG/cd/param/key), $config, $CONFIG/cd, $output, $TYPE_NUMBER),
    cm:build-query(fn:lower-case(map:get($params, $CONFIG/ccode/param/key)), $config, $CONFIG/ccode, 
      $output, $TYPE_WORD),
    cm:build-query(fn:lower-case(map:get($params, $CONFIG/ctype/param/key)), $config, $CONFIG/ctype,
      $output, $TYPE_WORD),
    cm:build-query(map:get($params, $CONFIG/ppn/param/key), $config, $CONFIG/ppn,
      $output, $TYPE_WORD)
  )
  return
    if(fn:empty($queries)) then ()
    else if(fn:count($queries) = 1) then $queries
    else 
      if($output = $qh:OUTPUT_JSON) then 
        let $json := json:object()
        let $array :=
          let $target := json:array()
          let $_ := for $query in $queries return json:array-push($target, $query)
          return $target
        let $queryobject :=
          let $object := json:object()
          let $_ := map:put($object, "queries", $array)
          return $object
        let $_ := map:put($json, "or-query", $queryobject)
        return $json
      else cts:or-query($queries)
};


declare function cm:build-query($term as xs:string*, $config as map:map, $defaults as element(),
  $output as xs:string, $type as xs:string) {
  let $_ := (
    fn:trace("build-query -- called", $TRACE_LEVEL_DETAIL),
    fn:trace(" -- defaults:" || xdmp:quote($defaults), $TRACE_LEVEL_FINE),
    fn:trace(" -- output:" || $output, $TRACE_LEVEL_FINE),
    fn:trace(" -- type:" || $type, $TRACE_LEVEL_FINE)
  )
  return
  if(cm:is-string-empty($term)) then ()
  else
    let $algorithm := cm:read-map-value($config, $defaults/param/algorithm, $defaults/algorithm)
    return
      if($algorithm = $ALG_TOKEN_MATCH) then
        (: tokenize the term.  each matching part contributes to the score :)
        let $parts := 
          for $part in fn:tokenize($term, $defaults/separator)
          where fn:string-length($part) > 1
          return $part
        let $weight := cm:read-map-value($config, $defaults/param/weight, $defaults/token-weight)
        for $property in $defaults/property
        let $query := qh:word-q($property, $parts, (), $weight, $output)
        let $_ := fn:trace(fn:concat(" -- query:",  
          if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
          else xdmp:quote($query)), $TRACE_LEVEL_FINE)
        return $query
      else if($algorithm = $ALG_DICTIONARY) then
        (: Get similar terms from a dictionary.  Matches to the primary term are
           assigned the full weight while matches to similar terms are adjusted by a multiplier :)
        let $similar := 
          if($type = $TYPE_NUMBER) then 
            dict:get-similar-numbers($term, $defaults/dictionary, 
              cm:read-map-value($config, $defaults/param/edit-distance, $defaults/edit-distance),
              cm:read-map-value($config,$defaults/param/word-distance, $defaults/word-distance),
              cm:read-map-value($config, $defaults/param/similar-limit, $defaults/similar-limit))
          else
            dict:get-similar-words($term, $defaults/dictionary, 
              cm:read-map-value($config, $defaults/param/word-distance, $defaults/word-distance),
              cm:read-map-value($config, $defaults/param/similar-limit, $defaults/similar-limit))
        let $weight := cm:read-map-value($config, $defaults/param/weight, $defaults/weight)
        for $property in $defaults/property
        let $query := qh:value-q($property, $term, (), $weight, $output)
        let $similar-query := 
          if(fn:empty($similar)) then ()
          else qh:value-q($property, $similar, (), $weight *
            cm:read-map-value($config, $defaults/param/weight-multiplier, $defaults/multiplier),
            $output
          )
        let $_ := (
          fn:trace(fn:concat(" -- query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
            else xdmp:quote($query)), $TRACE_LEVEL_FINE),
          fn:trace(fn:concat(" -- similar-query:", 
            if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($similar-query)
            else xdmp:quote($similar-query)), $TRACE_LEVEL_FINE)
        )
        return ($query, $similar-query)
      else  (: Default search is to just try to match on the term :)
        let $weight := cm:read-map-value($config, $defaults/param/weight, $defaults/weight)
        for $property in $defaults/property
        let $query := qh:value-q($property, $term, (), $weight, $output)
        let $_ := fn:trace(fn:concat(" -- query:", 
          if($output = $qh:OUTPUT_JSON) then xdmp:to-json-string($query)
          else xdmp:quote($query)), $TRACE_LEVEL_FINE)
        return $query
};

declare function cm:algorithm-new($params as map:map, $config as map:map) {
  let $_ := fn:trace("algorithm-new -- CALLED", $TRACE_LEVEL_TRACE)
  let $target := map:get($params, "target")
  let $query := cm:get-query($params, $config, "xquery")
  let $collection := cts:collection-query("ParticipationDetail")
  let $candidates := 
    if(fn:empty($query)) then ()
    else 
      cts:search(fn:doc(), cts:and-query(($query, $collection)), 
        ("score-simple","unfiltered", cm:get-sort-options($params)))[1 to 
          cm:read-map-value($params, $CONFIG/config/result-limit/key, $CONFIG/config/result-limit/value)]
  let $_ := fn:trace(fn:concat(" -- Candidates found:", fn:string(cts:remainder($candidates[1]))), $TRACE_LEVEL_TRACE)
  let $array := json:array()
  let $_ := (
    for $candidate in $candidates
    let $candidate-entry := json:object()
    let $score := qh:score($candidate)
    let $_ := (
      map:put($candidate-entry, "candidate", $candidate),
      map:put($candidate-entry, "score", $score)
    )
    where $score >= cm:read-map-value($params, $CONFIG/config/min-score/key, $CONFIG/config/min-score/value)
    return json:array-push($array, $candidate-entry)
  )
  let $json := json:object()
  let $_ := (
    map:put($json, "results", $array),
    map:put($json, "count", json:array-size($array)),
    map:put($json, "params", $params),
    map:put($json, "config", $config)
  )       
  return $json 
};

declare function cm:get-sort-options($params as map:map) {
  let $sort-string := cm:read-map-value($params, $CONFIG/config/sort/key, $CONFIG/config/sort/value)
  return cm:parse-sort-option($sort-string)
};

declare function cm:parse-sort-option($sort-string as xs:string) {
  let $option := fn:substring($sort-string, 1, 3)
  let $next := fn:substring($sort-string, 4)
  return (
    if($option = "wsd") then cts:score-order("descending")
    else if($option = "wsa") then cts:score-order("ascending")
    else if($option = "ctd") then cts:index-order(cts:element-reference(xs:QName("CaseType"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "descending")
    else if($option = "cta") then cts:index-order(cts:element-reference(xs:QName("CaseType"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "ascending")
    else if($option = "std") then cts:index-order(cts:element-reference(xs:QName("status"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "descending")
    else if($option = "sta") then cts:index-order(cts:element-reference(xs:QName("status"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "ascending")
    else if($option = "cdd") then cts:index-order(cts:element-reference(xs:QName("CloseDate"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "descending")
    else if($option = "cda") then cts:index-order(cts:element-reference(xs:QName("CloseDate"), 
      (type="xs:string", collation="http://marklogic.com/collation/codepoint")), "ascending")
    else (),
    if(fn:empty($next) or fn:string-length($next) = 0) then ()
    else cm:parse-sort-option($next)
};