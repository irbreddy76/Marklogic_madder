module namespace qh = 'http://marklogic.com/query-helper';

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
 :)
declare function qh:value-q($name as xs:string, $term as xs:string*, $options as xs:string*,
  $weight as xs:double) as cts:query? {
    cts:json-property-value-query($name, $term, $options, $weight div 8)
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
 :)
declare function qh:word-q($name as xs:string, $term as xs:string*, $options as xs:string*, 
  $weight as xs:double) as cts:query? {
    cts:json-property-word-query($name, $term, $options, $weight div 8)
};