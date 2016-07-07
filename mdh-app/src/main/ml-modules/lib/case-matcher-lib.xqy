module namespace cm = 'http://marklogic.com/case-matcher';

import module namespace qh = 'http://marklogic.com/query-helper' at
  '/lib/query-helper.xqy';

(: Enumerated values :)
declare variable $TRACE_LEVEL_TRACE as xs:string := "CASE-MATCH-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "CASE-MATCH-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "CASE-MATCH-FINE";
declare variable $CONFIG := 
<configuration>
  <status>
    <!-- Property name used for JSON queries -->
    <property>status</property>
    <!-- Key values used on the parameter and config maps -->
    <type>{$qh:TYPE_STRING}</type>
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
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </status>
  <cd>
    <!-- Property name used for JSON queries -->
    <property>CloseDate</property>
    <separator>-</separator>
    <type>{$qh:TYPE_STRING}</type>
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
    <weight type="xs:double">36</weight>
    <token-weight type="xs:double">12</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_TOKEN_MATCH}</algorithm>
  </cd>  
  <ccode>
    <!-- Property name used for JSON queries -->
    <property>CloseCode</property>
    <type>{$qh:TYPE_STRING}</type>
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
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </ccode>
  <ctype>
    <!-- Property name used for JSON queries -->
    <property>CaseType</property>
    <type>{$qh:TYPE_STRING}</type>
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
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </ctype>
  <ppn>
    <!-- Property name used for JSON queries -->
    <property>ParticipationProgramName</property>
    <type>{$qh:TYPE_STRING}</type>
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
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </ppn>
  <caseId>
    <!-- Property name used for JSON queries -->
    <property>serviceCaseId</property>
    <type>{$qh:TYPE_NUMBER}</type>
    <param>
      <key>caseId</key>
      <algorithm>caseId_algorithm</algorithm>
      <weight>caseId_wt</weight>
      <edit-distance>caseId_edit_distance</edit-distance>
      <word-distance>caseId_word_distance</word-distance>
      <weight-multiplier>caseId_mult</weight-multiplier>
      <similar-limit>caseId_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">36</weight>
    <token-weight type="xs:double">12</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </caseId>  
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
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/status/param/key)), $config, $CONFIG/status, 
      $output),    
    qh:build-query(map:get($params, $CONFIG/cd/param/key), $config, $CONFIG/cd, $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/ccode/param/key)), $config, $CONFIG/ccode,
      $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/ctype/param/key)), $config, $CONFIG/ctype,
      $output),    
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/ppn/param/key)), $config, $CONFIG/ppn,
      $output),
    qh:build-query(map:get($params, $CONFIG/caseId/param/key), $config, $CONFIG/caseId, 
      $output)    
  )
  return
    qh:get-response-object((), $queries, $output)
};



declare function cm:algorithm-new($params as map:map, $config as map:map) {
  let $_ := fn:trace("algorithm-new -- CALLED", $TRACE_LEVEL_TRACE)
  let $target := map:get($params, "target")
  let $query := cm:get-query($params, $config, "xquery")
  let $collection := 
    if($target = "personParticipation") then cts:collection-query("PersonParticipation")
    else cts:collection-query("ParticipationDetail")  
  let $candidates := 
    if(fn:empty($query)) then ()
    else 
      cts:search(fn:doc(), cts:and-query(($query, $collection)), 
        ("score-simple","unfiltered", cm:get-sort-options($params)))[1 to 
          qh:read-map-value($params, $CONFIG/config/result-limit/key, $CONFIG/config/result-limit/value)]
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
    where $score >= qh:read-map-value($params, $CONFIG/config/min-score/key, $CONFIG/config/min-score/value)
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
  let $sort-string := qh:read-map-value($params, $CONFIG/config/sort/key, $CONFIG/config/sort/value)
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
  )
};