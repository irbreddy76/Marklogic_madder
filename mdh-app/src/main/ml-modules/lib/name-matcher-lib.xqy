module namespace nm = 'http://marklogic.com/name-matcher';

import module namespace qh = 'http://marklogic.com/query-helper' at
  '/lib/query-helper.xqy';
import module namespace ah = 'http://marklogic.com/address-helper' at
  '/lib/address-helper.xqy';
    
(: Dictionary URIs :)
declare variable $DICTIONARY_LAST_NAME as xs:string := "/dictionaries/last-names.xml";
declare variable $DICTIONARY_MALE_NAMES as xs:string := "/dictionaries/male-first-names.xml";
declare variable $DICTIONARY_FEMALE_NAMES as xs:string := "/dictionaries/female-first-names.xml";

(: Enumerated values :)
declare variable $GENDER_MALE as xs:string := "M";
declare variable $GENDER_FEMALE as xs:string := "F";
declare variable $GENDER_UNSPECIFIED as xs:string := "U";
declare variable $SEPARATOR_DATE as xs:string := "-";
declare variable $SEPARATOR_SSN as xs:string := "-";
declare variable $SEPARATOR_ZIP as xs:string := "-";
declare variable $SEPARATOR_PHONE as xs:string := "-";
declare variable $OPERATOR_EQUALS as xs:string := "=";
declare variable $OPERATOR_LESS_THAN as xs:string := "<";
declare variable $OPERATOR_LESS_THAN_OR_EQUAL as xs:string := "<=";
declare variable $OPERATOR_GREATER_THAN as xs:string := ">";
declare variable $OPERATOR_GREATER_THAN_OR_EQUAL as xs:string := ">=";
declare variable $TRACE_LEVEL_TRACE as xs:string := "NAME-MATCH-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "NAME-MATCH-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "NAME-MATCH-FINE";
declare variable $SUFFIX_WEIGHT as xs:string := "weight";
declare variable $SUFFIX_MULTIPLIER as xs:string := "multiplier";

(: Argument Parameter Names :)
declare variable $PARAM_SSN as xs:string := "id";
declare variable $PARAM_DOB as xs:string := "dob";
declare variable $PARAM_MIDDLE_NAME as xs:string := "middle";
declare variable $PARAM_LAST_NAME as xs:string := "last";
declare variable $PARAM_FIRST_NAME as xs:string := "first";
declare variable $PARAM_MAIDEN_NAME as xs:string := "maiden";
declare variable $PARAM_STREET as xs:string := "street";
declare variable $PARAM_CITY as xs:string := "city";
declare variable $PARAM_STATE as xs:string := "state";
declare variable $PARAM_ZIP as xs:string := "zip";
declare variable $PARAM_RACE as xs:string := "race";
declare variable $PARAM_EMAIL as xs:string := "email";
declare variable $PARAM_PHONE as xs:string := "phone"; 
declare variable $PARAM_WEIGHT_SUFFIX as xs:string := "_wt";
declare variable $PARAM_MIN_SCORE as xs:string := "minscore";
declare variable $PARAM_MAX_DISTANCE as xs:string := "maxdist";
declare variable $PARAM_MAX_RESULTS as xs:string := "maxcount";
declare variable $PARAM_MULTIPLIER_SUFFIX as xs:string := "_mult";
declare variable $PARAM_GENDER as xs:string := "gender";

(: Default Weights :)
declare variable $WEIGHT_SSN as xs:double := 37;
declare variable $WEIGHT_SSN_AREA as xs:double := $WEIGHT_SSN;
declare variable $WEIGHT_SSN_GROUP as xs:double := $WEIGHT_SSN;
declare variable $WEIGHT_SSN_SERIAL as xs:double := $WEIGHT_SSN;
declare variable $WEIGHT_DOB as xs:double := 10;
declare variable $WEIGHT_DOB_YEAR as xs:double := $WEIGHT_DOB;
declare variable $WEIGHT_DOB_MONTH as xs:double := $WEIGHT_DOB;
declare variable $WEIGHT_DOB_DAY as xs:double := $WEIGHT_DOB;
declare variable $WEIGHT_GENDER as xs:double := 5;
declare variable $WEIGHT_NAME as xs:double := 27;
declare variable $WEIGHT_NAME_FIRST as xs:double := $WEIGHT_NAME;
declare variable $WEIGHT_NAME_MIDDLE as xs:double := $WEIGHT_NAME;
declare variable $WEIGHT_NAME_LAST as xs:double := $WEIGHT_NAME;
declare variable $WEIGHT_NAME_MAIDEN as xs:double := $WEIGHT_NAME;
declare variable $WEIGHT_STREET as xs:double := 10;
declare variable $WEIGHT_CITY as xs:double := 6;
declare variable $WEIGHT_STATE as xs:double := 2;
declare variable $WEIGHT_ZIP as xs:double := 5;
declare variable $WEIGHT_ZIP_EXTENSION as xs:double := 2.5;
declare variable $WEIGHT_EMAIL as xs:double := 5;
declare variable $WEIGHT_PHONE as xs:double := 5;
declare variable $WEIGHT_PHONE_AREA as xs:double := $WEIGHT_PHONE;
declare variable $WEIGHT_PHONE_INTERCHANGE as xs:double := $WEIGHT_PHONE;
declare variable $WEIGHT_PHONE_NUMBER as xs:double := $WEIGHT_PHONE;
declare variable $WEIGHT_PHONE_EXTENSION as xs:double := $WEIGHT_PHONE;
declare variable $WEIGHT_RACE as xs:double := 5;
declare variable $MULTIPLIER as xs:double := 0.5;

(: JSON Property Names :)
declare variable $PROPERTY_SSN as xs:string := "IdentificationID";
declare variable $PROPERTY_DOB as xs:string := "PersonBirthDate";
declare variable $PROPERTY_MIDDLE_NAME as xs:string := "PersonMiddleName";
declare variable $PROPERTY_LAST_NAME as xs:string := "PersonSurName";
declare variable $PROPERTY_FIRST_NAME as xs:string := "PersonGivenName";
declare variable $PROPERTY_MAIDEN_NAME as xs:string := "PersonMaidenName";
declare variable $PROPERTY_STREET as xs:string := "LocationStreet";
declare variable $PROPERTY_CITY as xs:string := "LocationCityName";
declare variable $PROPERTY_STATE as xs:string := "LocationStateName";
declare variable $PROPERTY_ZIP as xs:string := "LocationPostalCode";
declare variable $PROPERTY_ZIP_EXTENSION as xs:string := "LocationPostalCodeExtension";
declare variable $PROPERTY_RACE as xs:string := "PersonRaceCode";
declare variable $PROPERTY_EMAIL as xs:string := "ContactEmailID";
declare variable $PROPERTY_PHONE as xs:string := "FullTelephoneNumber"; 
declare variable $PROPERTY_GENDER as xs:string := "PersonSexCode";

(: Algorithm Thresholds :)
declare variable $MAX_RESULTS as xs:integer := 100;
declare variable $MAX_DISTANCE as xs:integer := 30;
declare variable $MIN_SCORE as xs:integer := 0;

(: Old Variables 
declare variable $ALG_CONFIG_SCORE_SSN as xs:integer := 37;
declare variable $ALG_CONFIG_SCORE_DOB_YEAR as xs:integer := 8;
declare variable $ALG_CONFIG_SCORE_DOB_MONTH as xs:integer := 5;
declare variable $ALG_CONFIG_SCORE_DOB_DAY as xs:integer := 10;
declare variable $ALG_CONFIG_SCORE_NAME_FIRST as xs:integer := 12;
declare variable $ALG_CONFIG_SCORE_NAME_LAST as xs:integer := 17;
declare variable $ALG_CONFIG_SCORE_ADDR_STATE as xs:integer := 2;
declare variable $ALG_CONFIG_SCORE_ADDR_CITY as xs:integer := 6;
declare variable $ALG_CONFIG_SCORE_ADDR_POSTAL_CODE as xs:integer := 5;
declare variable $ALG_CONFIG_SCORE_ADDR_STREET_LINE as xs:integer := 10;
declare variable $ALG_CONFIG_SCORE_EMAIL as xs:integer := 24;
:)

(: Helper Functions :)
declare function nm:is-string-empty($string as xs:string*) as xs:boolean { 
  if(empty($string) or $string = "") then fn:true() else fn:false()
};

declare function nm:get-suffixed-param-name($param-name as xs:string, 
  $suffix as xs:string) as xs:string {
  fn:concat($param-name, 
    if($suffix = $SUFFIX_WEIGHT) then $PARAM_WEIGHT_SUFFIX
    else $PARAM_MULTIPLIER_SUFFIX
  )
};

declare function nm:get-dictionary-options($distance as xs:integer?) as element() {
  <options xmlns="http://marklogic.com/xdmp/spell">
    <maximum>{$MAX_RESULTS}</maximum>
    <distance-threshold>
      {if(fn:empty($distance)) then $MAX_DISTANCE else $distance}
    </distance-threshold>
  </options>
};

declare function nm:read-map-value($map as map:map, $key as xs:string, 
  $default as xs:anyAtomicType?) as xs:anyAtomicType? {
  let $value := map:get($map, $key)
  return
    if(fn:empty($value)) then $default else 
      if($default instance of xs:date) then xs:date($value)
      else if($default instance of xs:dateTime) then xs:dateTime($value)
      else if($default instance of xs:time) then xs:time($value)
      else if($default instance of xs:duration) then xs:duration($value)
      else if($default instance of xs:float) then xs:float($value)
      else if($default instance of xs:double) then xs:double($value)
      else if($default instance of xs:decimal) then xs:decimal($value)
      else if($default instance of xs:string) then xs:string($value)
      else if($default instance of xs:boolean) then xs:boolean($value)
      else $value
};

(: Query Builders :)
declare function nm:build-person-query($params as map:map) as cts:query? {
  let $queries := (
    nm:build-ssn-query(map:get($params, $PARAM_SSN), 
      nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_SSN, $SUFFIX_WEIGHT), $WEIGHT_SSN),
      nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_SSN, $SUFFIX_MULTIPLIER), $MULTIPLIER)
    ),
    nm:build-dob-query(map:get($params, $PARAM_DOB), 
      nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_DOB, $SUFFIX_WEIGHT), $WEIGHT_DOB),
      nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_DOB, $SUFFIX_MULTIPLIER), $MULTIPLIER)
    ),
    let $gender := nm:read-map-value($params, $PARAM_GENDER, $GENDER_UNSPECIFIED)
    return 
      if($gender = $GENDER_UNSPECIFIED) then ()
      else 
        let $weight := nm:read-map-value($params, 
            nm:get-suffixed-param-name($PARAM_GENDER, $SUFFIX_WEIGHT), $WEIGHT_GENDER
        )
        let $fuzzy-weight := $weight * nm:read-map-value($params, 
            nm:get-suffixed-param-name($PARAM_GENDER, $SUFFIX_MULTIPLIER), $MULTIPLIER
          )
        return qh:value-q($PROPERTY_GENDER, $gender, (), $weight),
    nm:build-query($PROPERTY_RACE, map:get($params, $PARAM_RACE), (),
      nm:read-map-value($params, 
        nm:get-suffixed-param-name($PARAM_RACE, $SUFFIX_WEIGHT), $WEIGHT_RACE
      )
    ),
    nm:build-name-query($params)
  )
  let $_ :=
    for $query in $queries
    return fn:trace(fn:concat(" -- Query:", xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
  return
    if(fn:empty($queries)) then ()
    else cts:or-query($queries)
};

declare function nm:build-ssn-query($ssn as xs:string?, $weight as xs:double, $multiplier as xs:double)
  as cts:query? {
  if(nm:is-string-empty($ssn)) then ()
  else
    let $fuzzy-query := 
      if(fn:empty($ssn)) then ()
      else
        let $parts := fn:tokenize($ssn, $SEPARATOR_SSN)
        let $fuzzy-multiplier := $weight * $multiplier
        return (
          (: Ideally, we also store the 3 SSN parts for fuzzy matching :)
          qh:word-q($PROPERTY_SSN, fn:concat($parts[1], $SEPARATOR_SSN), (), $fuzzy-multiplier),
          qh:word-q($PROPERTY_SSN, fn:concat($SEPARATOR_SSN, $parts[2], $SEPARATOR_SSN), (), $fuzzy-multiplier),
          qh:word-q($PROPERTY_SSN, fn:concat($SEPARATOR_SSN, $parts[3]), (), $fuzzy-multiplier)          
        )
    return cts:or-query((qh:value-q($PROPERTY_SSN, $ssn, (), $weight), $fuzzy-query))
};

declare function nm:build-dob-query($dob as xs:string?, $weight as xs:double, $multiplier as xs:double)
  as cts:query? {
  if(nm:is-string-empty($dob)) then ()
  else
    let $fuzzy-query := 
      let $parts := fn:tokenize($dob, $SEPARATOR_DATE)
      let $fuzzy-multiplier := $weight * $multiplier
      return (
        (: Ideally, we also store the 3 date tokens separately for fuzzy matching :)
        qh:word-q($PROPERTY_DOB, fn:concat($parts[1], $SEPARATOR_DATE), (), $fuzzy-multiplier),
        qh:word-q($PROPERTY_DOB, fn:concat($SEPARATOR_DATE, $parts[2], $SEPARATOR_DATE), (), $fuzzy-multiplier),
        qh:word-q($PROPERTY_DOB, fn:concat($SEPARATOR_DATE, $parts[3]), (), $fuzzy-multiplier)
      )
    return cts:or-query((qh:range-q($PROPERTY_DOB, xs:date($dob), $OPERATOR_EQUALS, (), $weight), $fuzzy-query))
};

declare function nm:build-name-query($params as map:map) as cts:query? {
  let $queries := (
    nm:build-firstname-query($params),
    nm:build-surname-query($params)
  )
  let $middle-q := 
    let $middle := fn:lower-case(map:get($params, $PARAM_MIDDLE_NAME))
    return
      nm:build-query($PROPERTY_MIDDLE_NAME, $middle, (),  
        nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_MIDDLE_NAME, $SUFFIX_WEIGHT), $WEIGHT_NAME)
      )
  return
    if(fn:empty(($queries, $middle-q))) then ()
    else 
      cts:or-query((
        if(fn:empty($queries)) then () else cts:and-query($queries),
        $middle-q
      ))
};

declare function nm:build-surname-query($params as map:map) as cts:query? {
  let $surname := fn:lower-case(map:get($params, $PARAM_LAST_NAME))
  return
    if(nm:is-string-empty($surname)) then ()
    else
      let $similar-names := nm:get-similar-names($surname, $DICTIONARY_LAST_NAME, 
        nm:get-dictionary-options(map:get($params, $PARAM_MAX_DISTANCE)))
      let $gender := nm:read-map-value($params, $PARAM_GENDER, $GENDER_UNSPECIFIED)
      let $weight := nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_LAST_NAME, $SUFFIX_WEIGHT), $WEIGHT_NAME)
      let $fuzzy-multiplier := $weight *
        nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_LAST_NAME, $SUFFIX_MULTIPLIER), $MULTIPLIER)
      let $queries := (
        qh:value-q($PROPERTY_LAST_NAME, $surname, (), $weight),
        if(fn:empty($similar-names)) then () else
          qh:value-q($PROPERTY_LAST_NAME, $similar-names, (), $fuzzy-multiplier),
        if($gender = $GENDER_MALE) then ()
        else (
          qh:value-q($PROPERTY_MAIDEN_NAME, $surname, (), $weight),
          if(fn:empty($similar-names)) then () else
          qh:value-q($PROPERTY_MAIDEN_NAME, $similar-names, (), $fuzzy-multiplier)
        )
      )
      return cts:or-query($queries)
};

declare function nm:build-firstname-query($params as map:map) as cts:query? {
  let $firstname := fn:lower-case(map:get($params, $PARAM_FIRST_NAME)) 
  return
    if(nm:is-string-empty($firstname)) then ()
    else
      let $gender := nm:read-map-value($params, $PARAM_GENDER, $GENDER_UNSPECIFIED)
      let $similar-names := nm:get-similar-names($firstname, 
        if($gender = $GENDER_MALE) then $DICTIONARY_MALE_NAMES
        else if($gender = $GENDER_FEMALE) then $DICTIONARY_FEMALE_NAMES
        else ($DICTIONARY_MALE_NAMES, $DICTIONARY_FEMALE_NAMES),
        nm:get-dictionary-options(map:get($params, $PARAM_MAX_DISTANCE))
      )
      let $weight := nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_FIRST_NAME, $SUFFIX_WEIGHT), $WEIGHT_NAME)
      let $fuzzy-multiplier := $weight *
        nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_FIRST_NAME, $SUFFIX_MULTIPLIER), $MULTIPLIER)
      let $queries := (
        qh:value-q($PROPERTY_FIRST_NAME, $firstname, (), $weight),
        if(fn:empty($similar-names)) then () else
          qh:value-q($PROPERTY_FIRST_NAME, $similar-names, (), $fuzzy-multiplier)
      )
      return cts:or-query($queries)
};

declare function nm:build-contact-query($params as map:map) as cts:query? {
  let $street := fn:lower-case(map:get($params, $PARAM_STREET))
  let $city := fn:lower-case(map:get($params, $PARAM_CITY))
  let $state := fn:lower-case(map:get($params, $PARAM_STATE))
  let $zip := map:get($params, $PARAM_ZIP)
  let $validated-address := if((nm:is-string-empty($street),
    nm:is-string-empty($city), nm:is-string-empty($state), nm:is-string-empty($zip))) then ()
    else ah:validate-address($street, $city, $state, $zip)
  let $queries := (
    if(nm:is-string-empty($street)) then () 
    else
      ah:build-street-query($PROPERTY_STREET, $street, $validated-address/LocationStreet,
        nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_STREET, $SUFFIX_WEIGHT), $WEIGHT_STREET),
        nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_STREET, $SUFFIX_MULTIPLIER), $MULTIPLIER)
      ),
    if(nm:is-string-empty($city)) then () 
    else
      ah:build-citystate-query($PROPERTY_CITY, $city, $validated-address/LocationCityName,
        nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_CITY, $SUFFIX_WEIGHT), $WEIGHT_CITY)),
    if(nm:is-string-empty($state)) then () 
    else
      ah:build-citystate-query($PROPERTY_STATE, $state, $validated-address/LocationStateName,
        nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_STATE, $SUFFIX_WEIGHT), $WEIGHT_STATE)),
    if(nm:is-string-empty($zip)) then ()
    else
      let $zip-parts := fn:tokenize($zip, $SEPARATOR_ZIP)
      return (
        ah:build-zip-query($PROPERTY_ZIP, $zip-parts[1], $validated-address/LocationPostalCode,
          nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_ZIP, $SUFFIX_WEIGHT), $WEIGHT_ZIP)),
        ah:build-zip-query($PROPERTY_ZIP, $zip-parts[2], $validated-address/LocationPostalCodeExtension,
          nm:read-map-value($params, nm:get-suffixed-param-name(fn:concat($PARAM_ZIP, "ext"), $SUFFIX_WEIGHT), 
            $WEIGHT_ZIP_EXTENSION))
      ),
    nm:build-query($PROPERTY_EMAIL, fn:lower-case(map:get($params, $PARAM_EMAIL)), (),
      nm:read-map-value($params, nm:get-suffixed-param-name($PARAM_EMAIL, $SUFFIX_WEIGHT),
        $WEIGHT_EMAIL)
    ),
    nm:build-phone-query($params)
  )
  let $_ :=
    for $query in $queries
    return fn:trace(fn:concat(" -- Query:", xdmp:quote($query)), $TRACE_LEVEL_DETAIL)
  return
    if(fn:empty($queries)) then ()
    else cts:or-query($queries)
};

declare function nm:build-query($property as xs:string, $terms as xs:string*, $options as xs:string*,
  $weight as xs:double) as cts:query? {
    if(nm:is-string-empty($terms)) then ()
    else qh:value-q($property, $terms, $options, $weight)
};

declare function nm:build-phone-query($params as map:map) as cts:query? {
  let $phone := map:get($params, $PARAM_PHONE)
  return
    if(nm:is-string-empty($phone)) then ()
    else
      let $weight := nm:read-map-value($params, 
        nm:get-suffixed-param-name($PARAM_PHONE, $SUFFIX_WEIGHT), $WEIGHT_PHONE)
      let $fuzzy-weight := $weight *
        nm:read-map-value($params, 
          nm:get-suffixed-param-name($PARAM_PHONE, $SUFFIX_MULTIPLIER), $MULTIPLIER)
      let $fuzzy-query := 
        let $parts := fn:tokenize(
          fn:replace(
            fn:replace($phone, "(", ""), ")", $SEPARATOR_PHONE
          ), $SEPARATOR_PHONE)
        return (
          qh:word-q($PROPERTY_PHONE, fn:concat("(", $parts[1], ")"), (), $fuzzy-weight),
          qh:word-q($PROPERTY_PHONE, fn:concat($parts[2], $SEPARATOR_PHONE), (), $fuzzy-weight),
          qh:word-q($PROPERTY_PHONE, fn:concat($SEPARATOR_PHONE, $parts[3]), (), $fuzzy-weight)
        )
      return cts:or-query((qh:value-q($PROPERTY_PHONE, $phone, (), $weight), $fuzzy-query))
};

(: Check against name dictionary :)
declare function nm:get-similar-names($name as xs:string, $dictionaries as xs:string*, 
  $dictionary-options as element()?) as xs:string* {
  for $candidate in spell:suggest-detailed($dictionaries, $name, $dictionary-options)
  let $similar-name := $candidate/spell:word
  where nm:compare-metaphone($name, $similar-name) and
    $name != $similar-name and $similar-name/@distance <= $MAX_DISTANCE
  return $similar-name
};

(: filter names by sound :)
declare function nm:compare-metaphone($original as xs:string, $target as xs:string) as xs:boolean {
  let $original-meta := spell:double-metaphone($original)
  let $target-meta := spell:double-metaphone($target)
  let $_ := (
    fn:trace(fn:string-join((" -- Original:", $original-meta), " "), $TRACE_LEVEL_FINE),
    fn:trace(fn:string-join((" -- Target:", $target-meta), " "), $TRACE_LEVEL_FINE)
  )
  return
    if(($original-meta[1] = $target-meta[1]) and 
      ($original-meta[2] = $target-meta[2])) then fn:true()
    else fn:false()
};

declare function nm:algorithm-new($params as map:map) {
  let $_ := (
    fn:trace("nm:algorithm-new CALLED", $TRACE_LEVEL_TRACE),
    for $key in map:keys($params)
    return fn:trace(fn:concat(" -- Param:", $key, "=", map:get($params, $key)), $TRACE_LEVEL_DETAIL)
  )  
  
  (: Person information :)
  let $_ := fn:trace(" -- Getting person info....", $TRACE_LEVEL_TRACE)
  let $personQuery := nm:build-person-query($params)
  
  (: Contact information :)
  let $_ := fn:trace(" -- Getting address info....", $TRACE_LEVEL_TRACE)
  let $contactQuery := nm:build-contact-query($params)
  
  let $candidates := 
    if(fn:empty(($personQuery, $contactQuery))) then ()
    else 
      cts:search(fn:doc(), cts:and-query(($personQuery, $contactQuery)), 
        ("score-simple","unfiltered", cts:score-order("descending")))[1 to nm:read-map-value($params, $PARAM_MAX_RESULTS, $MAX_RESULTS)]
  let $_ := fn:trace(fn:concat(" -- Candidates found:", fn:string(cts:remainder($candidates[1]))), 
    $TRACE_LEVEL_TRACE)
  let $array := json:array()
  let $_ := (
    for $candidate in $candidates
    let $candidate-entry := json:object()
    let $score := qh:score($candidate)
    let $_ := (
      map:put($candidate-entry, "candidate", $candidate),
      map:put($candidate-entry, "score", $score)
    )
    where $score >= nm:read-map-value($params, $PARAM_MIN_SCORE, $MIN_SCORE)
    return json:array-push($array, $candidate-entry)
  )
  let $json := json:object()
  let $_ := (
    map:put($json, "results", $array),
    map:put($json, "count", json:array-size($array)),
    map:put($json, "params", $params)
  )       
  return $json 
};