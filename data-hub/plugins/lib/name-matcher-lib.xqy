module namespace nm = 'http://marklogic.com/name-matcher';

import module namespace qh = 'http://marklogic.com/query-helper' at
  '/lib/query-helper.xqy';
import module namespace ah = 'http://marklogic.com/address-helper' at
  '/lib/address-helper.xqy';

(: Enumerated values :)
declare variable $TRACE_LEVEL_TRACE as xs:string := "NAME-MATCH-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "NAME-MATCH-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "NAME-MATCH-FINE";
declare variable $CONFIG := 
<configuration>
  <ssn>
    <!-- Property name used for JSON queries -->
    <property>SSNIdentificationId</property>
    <separator>-</separator>
    <type>{$qh:TYPE_NUMBER}</type> 
    <!--<dictionary>/dictionaries/ssn.xml</dictionary>-->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>ssn</key>
      <algorithm>ssn_algorithm</algorithm>
      <weight>ssn_wt</weight>
      <edit-distance>ssn_edit_distance</edit-distance>
      <word-distance>ssn_word_distance</word-distance>
      <weight-multiplier>ssn_mult</weight-multiplier>
      <similar-limit>ssn_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">36</weight>
    <token-weight type="xs:double">12</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </ssn>
  <dob>
    <!-- Property name used for JSON queries -->
    <property>PersonBirthDate</property>
    <separator>-</separator>
    <!--<dictionary>/dictionaries/birth-date.xml</dictionary>-->
    <!-- Key values used on the parameter and config maps -->
    <type>{$qh:RANGE_TYPE_DATE}</type>
    <param>
      <key>dob</key>
      <algorithm>dob_algorithm</algorithm>
      <time-range>dob_window</time-range>
      <weight>dob_wt</weight>
      <edit-distance>dob_edit_distance</edit-distance>
      <word-distance>dob_word_distance</word-distance>
      <weight-multiplier>dob_mult</weight-multiplier>
      <similar-limit>dob_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <time-window type="xs:yearMonthDuration">P3Y</time-window>
    <token-weight type="xs:double">8</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_TIME_WINDOW}</algorithm>
  </dob>
  <dob-from>
    <!-- Property name used for JSON queries -->
    <property>PersonBirthDate</property>
    <separator>-</separator>
    <!--<dictionary>/dictionaries/birth-date.xml</dictionary>-->
    <!-- Key values used on the parameter and config maps -->
    <type>{$qh:RANGE_TYPE_DATE}</type>
    <operator>{$qh:OPERATOR_GTE}</operator>
    <param>
      <key>dob-from</key>
      <algorithm>dob-from_algorithm</algorithm>
      <time-range>dob-from_window</time-range>
      <weight>dob-from_wt</weight>
      <edit-distance>dob-from_edit_distance</edit-distance>
      <word-distance>dob-from_word_distance</word-distance>
      <weight-multiplier>dob-from_mult</weight-multiplier>
      <similar-limit>dob-from_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">8</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </dob-from>
  <dob-to>
    <!-- Property name used for JSON queries -->
    <property>PersonBirthDate</property>
    <separator>-</separator>
    <!--<dictionary>/dictionaries/birth-date.xml</dictionary>-->
    <!-- Key values used on the parameter and config maps -->
    <type>{$qh:RANGE_TYPE_DATE}</type>
    <operator>{$qh:OPERATOR_LT}</operator>
    <param>
      <key>dob-to</key>
      <algorithm>dob-to_algorithm</algorithm>
      <time-range>dob-from_window</time-range>
      <weight>dob-to_wt</weight>
      <edit-distance>dob-to_edit_distance</edit-distance>
      <word-distance>dob-to_word_distance</word-distance>
      <weight-multiplier>dob-to_mult</weight-multiplier>
      <similar-limit>dob-to_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">8</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </dob-to>
  <middle>
    <!-- Property name used for JSON queries -->
    <property>PersonMiddleName</property>
    <separator> </separator>
    <type>{$qh:TYPE_STRING}</type>
    <dictionary>/dictionaries/male-first-names.xml</dictionary>
    <dictionary>/dictionaries/female-first-names.xml</dictionary>
    <dictionary>/dictionaries/last-names.xml</dictionary>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>middle</key>
      <algorithm>middle_algorithm</algorithm>
      <weight>middle_wt</weight>
      <word-distance>middle_word_distance</word-distance>
      <weight-multiplier>middle_mult</weight-multiplier>
      <similar-limit>middle_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">12</weight>
    <token-weight type="xs:double">8</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </middle>
  <first>
    <!-- Property name used for JSON queries -->
    <property>PersonGivenName</property>
    <separator> </separator>
    <type>{$qh:TYPE_STRING}</type>
    <dictionary>/dictionaries/male-first-names.xml</dictionary>
    <dictionary>/dictionaries/female-first-names.xml</dictionary>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>first</key>
      <algorithm>first_algorithm</algorithm>
      <weight>first_wt</weight>
      <word-distance>first_word_distance</word-distance>
      <weight-multiplier>first_mult</weight-multiplier>
      <similar-limit>first_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">18</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_DICTIONARY}</algorithm>
  </first>
  <last>
    <!-- Property name used for JSON queries -->
    <property>PersonSurName</property>
    <property>PersonMaidenName</property>
    <separator> </separator>
    <type>{$qh:TYPE_STRING}</type>
    <dictionary>/dictionaries/last-names.xml</dictionary>
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>last</key>
      <algorithm>last_algorithm</algorithm>
      <weight>last_wt</weight>
      <word-distance>last_word_distance</word-distance>
      <weight-multiplier>last_mult</weight-multiplier>
      <similar-limit>last_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">24</weight>
    <token-weight type="xs:double">18</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_DICTIONARY}</algorithm>
  </last>
  <race>
    <!-- Property name used for JSON queries -->
    <property>PersonRaceCode</property>
    <!-- <separator> </separator> -->
    <type>{$qh:TYPE_STRING}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>race</key>
      <algorithm>race_algorithm</algorithm>
      <weight>race_wt</weight>
      <word-distance>race_word_distance</word-distance>
      <weight-multiplier>race_mult</weight-multiplier>
      <similar-limit>race_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">12</weight>
    <!--<token-weight type="xs:double">18</token-weight>-->
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </race>
  <street>
    <!-- Property name used for JSON queries -->
    <property>LocationStreet</property>
    <separator> </separator>
    <type>{$qh:TYPE_STRING}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>street</key>
      <algorithm>street_algorithm</algorithm>
      <weight>street_wt</weight>
      <word-distance>street_word_distance</word-distance>
      <weight-multiplier>street_mult</weight-multiplier>
      <similar-limit>street_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">18</weight>
    <token-weight type="xs:double">6</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_TOKEN_MATCH}</algorithm>
  </street>
  <city>
    <!-- Property name used for JSON queries -->
    <property>LocationCityName</property>
    <separator> </separator>
    <type>{$qh:TYPE_STRING}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>city</key>
      <algorithm>city_algorithm</algorithm>
      <weight>city_wt</weight>
      <word-distance>city_word_distance</word-distance>
      <weight-multiplier>city_mult</weight-multiplier>
      <similar-limit>city_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">12</weight>
    <token-weight type="xs:double">6</token-weight>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_TOKEN_MATCH}</algorithm>
  </city>
  <state>
    <!-- Property name used for JSON queries -->
    <property>LocationStateName</property>
    <!-- <separator> </separator> -->
    <type>{$qh:TYPE_STRING}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>state</key>
      <algorithm>state_algorithm</algorithm>
      <weight>state_wt</weight>
      <word-distance>state_word_distance</word-distance>
      <weight-multiplier>state_mult</weight-multiplier>
      <similar-limit>state_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">6</weight>
    <!--<token-weight type="xs:double">18</token-weight>-->
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </state>
  <zip>
    <!-- Property name used for JSON queries -->
    <property>LocationPostalCode</property>
    <separator>-</separator>
    <type>{$qh:TYPE_NUMBER}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>zip</key>
      <algorithm>zip_algorithm</algorithm>
      <weight>zip_wt</weight>
      <edit-distance>zip_edit_distance</edit-distance>
      <word-distance>zip_word_distance</word-distance>
      <weight-multiplier>zip_mult</weight-multiplier>
      <similar-limit>zip_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">8</weight>
    <token-weight type="xs:double">4</token-weight>
    <edit-distance type="xs:integer">7</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </zip>
  <zipext>
    <!-- Property name used for JSON queries -->
    <property>LocationPostalCodeExtension</property>
    <separator>-</separator>
    <type>{$qh:TYPE_NUMBER}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>zipext</key>
      <algorithm>zipext_algorithm</algorithm>
      <weight>zipext_wt</weight>
      <edit-distance>zipext_edit_distance</edit-distance>
      <word-distance>zipext_word_distance</word-distance>
      <weight-multiplier>zipext_mult</weight-multiplier>
      <similar-limit>zipext_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">8</weight>
    <token-weight type="xs:double">4</token-weight>
    <edit-distance type="xs:integer">7</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </zipext>
  <phone>
    <!-- Property name used for JSON queries -->
    <property>FullTelephoneNumber</property>
    <separator>-</separator>
    <type>number</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>phone</key>
      <algorithm>phone_algorithm</algorithm>
      <weight>phone_wt</weight>
      <word-distance>phone_word_distance</word-distance>
      <weight-multiplier>phone_mult</weight-multiplier>
      <similar-limit>phone_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">9</weight>
    <token-weight type="xs:double">3</token-weight>
    <edit-distance type="xs:integer">4</edit-distance>
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_TOKEN_MATCH}</algorithm>
  </phone>
  <email>
    <!-- Property name used for JSON queries -->
    <property>ContactEmailId</property>
    <!-- <separator> </separator> -->
    <type>{$qh:TYPE_STRING}</type>
    <!-- <dictionary>/dictionaries/last-names.xml</dictionary> -->
    <!-- Key values used on the parameter and config maps -->
    <param>
      <key>email</key>
      <algorithm>email_algorithm</algorithm>
      <weight>email_wt</weight>
      <word-distance>email_word_distance</word-distance>
      <weight-multiplier>email_mult</weight-multiplier>
      <similar-limit>email_limit</similar-limit>
    </param>
    <!-- Default weights/values -->
    <weight type="xs:double">8</weight>
    <!--<token-weight type="xs:double">18</token-weight>-->
    <word-distance type="xs:integer">30</word-distance>
    <multiplier type="xs:double">0.5</multiplier>
    <similar-limit type="xs:integer">10</similar-limit>
    <algorithm type="xs:string">{$qh:ALG_NONE}</algorithm>
  </email>
  <config>
    <result-limit>
      <key>limit</key>
      <value type="xs:integer">10</value>
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


declare function nm:get-query($params as map:map, $config as map:map,  $output as xs:string) { 
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
  let $exact-queries := (
    qh:build-query(map:get($params, $CONFIG/dob-from/param/key), $config, $CONFIG/dob-from, $output),
    qh:build-query(map:get($params, $CONFIG/dob-to/param/key), $config, $CONFIG/dob-to, $output)
  )
  let $queries := (
    qh:build-query(map:get($params, $CONFIG/ssn/param/key), $config, $CONFIG/ssn, $output),
    qh:build-query(map:get($params, $CONFIG/dob/param/key), $config, $CONFIG/dob, $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/middle/param/key)), $config, $CONFIG/middle, 
      $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/first/param/key)), $config, $CONFIG/first,
      $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/last/param/key)), $config, $CONFIG/last,
      $output),    
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/race/param/key)), $config, $CONFIG/race,
      $output),
    qh:build-query(map:get($params, $CONFIG/phone/param/key), $config, $CONFIG/phone, $output),
    qh:build-query(fn:lower-case(map:get($params, $CONFIG/email/param/key)), $config, $CONFIG/email,
      $output),
    nm:build-address-query($params, $config, $output)
  )
  return qh:get-response-object($exact-queries, $queries, $output)
};

declare function nm:build-address-query($params as map:map, $config as map:map, $output as xs:string) {
  let $street := fn:lower-case(map:get($params, $CONFIG/street/param/key))
  let $city := fn:lower-case(map:get($params, $CONFIG/city/param/key))
  let $state := fn:lower-case(map:get($params, $CONFIG/state/param/key))
  let $zip := map:get($params, $CONFIG/zip/param/key)
  let $zip-ext := map:get($params, $CONFIG/zipext/param/key)
  let $usps-address := ah:validate-address($street, $city, $state, $zip, $zip-ext)
  return (
    qh:build-query(fn:distinct-values(($street, $usps-address/LocationStreet)), 
      $config, $CONFIG/street, $output),
    qh:build-query(fn:distinct-values(($city, $usps-address/LocationCityName)),
      $config, $CONFIG/city, $output),
    qh:build-query(fn:distinct-values(($state, $usps-address/LocationStateName)),
      $config, $CONFIG/state, $output),
    qh:build-query(fn:distinct-values(($zip, $usps-address/LocationPostalCode)), 
      $config, $CONFIG/zip, $output),
    qh:build-query(fn:distinct-values(($zip-ext, $usps-address/LocationPostalCodeExtension)),
      $config, $CONFIG/zipext, $output)
  )
};

declare function nm:algorithm-new($params as map:map, $config as map:map) {
  let $_ := fn:trace("algorithm-new -- CALLED", $TRACE_LEVEL_TRACE)
  let $target := map:get($params, "target")
  let $query := nm:get-query($params, $config, "xquery")
  let $collection := 
    if($target = "person") then cts:collection-query("Person")
    else if($target = "personparticipation") then cts:collection-query("MasterPerson")
    else cts:collection-query(("Person", "MasterPerson"))
  let $candidates := 
      cts:search(fn:doc(), cts:and-query(($query, $collection, cts:not-query(cts:collection-query("deleted")))), 
        ("score-simple","unfiltered", nm:get-sort-options($params)))[1 to 
          qh:read-map-value($params, $CONFIG/config/result-limit/key, $CONFIG/config/result-limit/value)]
  let $_ := fn:trace(fn:concat(" -- Candidates found:", fn:string(cts:remainder($candidates[1]))), $TRACE_LEVEL_TRACE)
  let $array := json:array()
  let $_ := (
    for $candidate in $candidates
    let $candidate-entry := json:object()
    let $score := qh:score($candidate)
    let $_ := (
      map:put($candidate-entry, "candidate", $candidate),
      map:put($candidate-entry, "uri", fn:document-uri($candidate)),
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

declare function nm:get-sort-options($params as map:map) {
  let $sort-string := qh:read-map-value($params, $CONFIG/config/sort/key, $CONFIG/config/sort/value)
  return nm:parse-sort-option($sort-string)
};

declare function nm:parse-sort-option($sort-string as xs:string) {
  let $option := fn:substring($sort-string, 1, 3)
  let $next := fn:substring($sort-string, 4)
  return (
    if($option = "wsd") then cts:score-order("descending")
    else if($option = "wsa") then cts:score-order("ascending")
    else if($option = "fnd") then cts:index-order(cts:element-reference(xs:QName("PersonGivenName"), 
      ('type=string', 'collation=')), "descending")
    else if($option = "fna") then cts:index-order(cts:element-reference(xs:QName("PersonGivenName"), 
      ('type=string', 'collation=')), "ascending")
    else if($option = "lnd") then cts:index-order(cts:element-reference(xs:QName("PersonSurName"), 
      ('type=string', 'collation=')), "descending")
    else if($option = "lna") then cts:index-order(cts:element-reference(xs:QName("PersonSurName"), 
      ('type=string', 'collation=')), "ascending")
    else if($option = "bdd") then cts:index-order(cts:element-reference(xs:QName("PersonBirthDate"), 
      ('type=date')), "descending")
    else if($option = "bda") then cts:index-order(cts:element-reference(xs:QName("PersonBirthDate"), 
      ('type=date')), "ascending")
    else (),
    if(fn:empty($next) or fn:string-length($next) = 0) then ()
    else nm:parse-sort-option($next)
  )
};
