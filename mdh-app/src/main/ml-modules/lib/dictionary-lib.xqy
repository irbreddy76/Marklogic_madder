module namespace d = 'http://marklogic.com/dictionary';

import module namespace spell = "http://marklogic.com/xdmp/spell" 
  at "/MarkLogic/spell.xqy";

declare variable $NUMBER_PREFIX as xs:string := "number:";
declare variable $TRACE_LEVEL_TRACE as xs:string := "DICTIONARY-HELPER-TRACE";
declare variable $TRACE_LEVEL_DEBUG as xs:string := "DICTIONARY-HELPER-DEBUG";

(:
 : To get dictionaries working with numbers we need to prepend the number with some
 : text.   We then remove that text before returning the number.   
 :)
declare function d:get-similar-numbers($term as xs:string, $dictionaries as xs:string*,
  $edit-distance as xs:integer, $word-distance as xs:integer, $limit as xs:integer) as xs:string* {
  let $_ := (
    fn:trace("get-similar-numbers -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- term=" || $term, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- dictionaries=" || fn:string-join($dictionaries, ","), $TRACE_LEVEL_DEBUG),
    fn:trace(" -- edit-distance=" || $edit-distance, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- word-distance=" || $word-distance, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- limit=" || $limit, $TRACE_LEVEL_DEBUG)
  )
  return 
    if(fn:empty($dictionaries)) then ()
    else
      for $candidate in spell:suggest-detailed($dictionaries, fn:concat($NUMBER_PREFIX, $term), 
        d:get-dictionary-options($word-distance, $limit))
      let $alternate := $candidate/spell:word
      where $alternate/@levenshtein-distance/xs:integer(.) <= $edit-distance and
        $alternate/@levenshtein-distance/xs:integer(.) > 0
      return fn:substring-after($alternate, $NUMBER_PREFIX)
};

declare function d:get-similar-words($term as xs:string, $dictionaries as xs:string*, 
  $word-distance as xs:integer, $limit as xs:integer) as xs:string* {
  let $_ := (
    fn:trace("get-similar-words -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- term=" || $term, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- dictionaries=" || fn:string-join($dictionaries, ","), $TRACE_LEVEL_DEBUG),
    fn:trace(" -- word-distance=" || $word-distance, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- limit=" || $limit, $TRACE_LEVEL_DEBUG)
  )
  return
    if(fn:empty($dictionaries)) then ()
    else
      for $candidate in spell:suggest-detailed($dictionaries, $term, 
        d:get-dictionary-options($word-distance, $limit))
      let $alternate := $candidate/spell:word
      where d:compare-metaphone($term, $alternate) and
        $alternate/@distance/xs:integer(.) > 0
      return $alternate
};

(:~
 : Checks the double-metaphone representation of the 2 strings for equivalence.
 : Returns true if both sound parts for each string match.
 :)
declare function d:compare-metaphone($original as xs:string, $target as xs:string) as xs:boolean {
  let $_ := (
    fn:trace("compare-metaphone -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- original=" || $original, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- target=" || $target, $TRACE_LEVEL_DEBUG)
  )
  let $original-meta := spell:double-metaphone($original)
  let $target-meta := spell:double-metaphone($target)
  let $_ := (
    fn:trace(fn:string-join((" -- Original Metaphone:", $original-meta), " "), $TRACE_LEVEL_DEBUG),
    fn:trace(fn:string-join((" -- Target Metaphone:", $target-meta), " "), $TRACE_LEVEL_DEBUG)
  )
  return
    if(($original-meta[1] = $target-meta[1]) and 
      ($original-meta[2] = $target-meta[2])) then fn:true()
    else fn:false()
};

(:~
 : Checks if a dictionary contains the specified term
 :)
declare function d:check-for-term($term as xs:string, $dictionary as xs:string) as xs:boolean {
  let $_ := (
    fn:trace("check-for-term -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- term=" || $term, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- dictionary=" || $dictionary, $TRACE_LEVEL_DEBUG)
  )
  let $results := cts:uris((), (), cts:and-query((
      cts:document-query($dictionary), 
      cts:element-value-query(xs:QName("spell:word"), $term, 
        ("case-insensitive", "diacritic-insensitive", "unstemmed"))
    )), "unfiltered")
  return 
    if(fn:empty($results)) then 
      let $_ := fn:trace(" -- term not found.", $TRACE_LEVEL_DEBUG)
      return fn:false()
    else 
      let $_ := fn:trace(" -- term found.", $TRACE_LEVEL_DEBUG)
      return fn:true()
};

(:~
 : Adds a term to the specified dictionary.  If the dictionary doesn't exist, 
 : create a new dictionary with the term.
 :)
declare function d:add-term($term as xs:string, $dictionary as xs:string) {
  d:add-dictionary-entry($term, $dictionary, ())
};

declare function d:add-dictionary-entry($term as xs:string, $dictionary as xs:string, $isNumber as xs:boolean?) {
  let $_ := (
    fn:trace("add-dictionary-entry -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- param:term=" || $term, $TRACE_LEVEL_DEBUG),
    fn:trace(" -- param:dictionary=" || $dictionary, $TRACE_LEVEL_DEBUG)
  )
  let $entry := (: Add number prefix if this is a numeric text that needs to be matched :)
    if($isNumber) then 
      let $_ := fn:trace(" -- param:isNumber=true", $TRACE_LEVEL_DEBUG)
      return fn:concat($NUMBER_PREFIX, $term)
    else $term
  return
    if(fn:doc-available($dictionary)) then 
      let $_ := fn:trace(" -- dictionary exists", $TRACE_LEVEL_DEBUG)
      return
        if(d:check-for-term($entry, $dictionary)) then () (: Term already exists :)
        else spell:add-word($dictionary, $entry)
    else 
      let $_ := fn:trace(" -- dictionary does not exist.  Creating", $TRACE_LEVEL_DEBUG)
      return spell:insert($dictionary, spell:make-dictionary($entry))
};

declare function d:get-dictionary-options($distance as xs:integer, $limit as xs:integer) as element(spell:options) {
  <options xmlns="http://marklogic.com/xdmp/spell">
    <maximum>{$limit}</maximum>
    <distance-threshold>{$distance}</distance-threshold>
  </options>
};