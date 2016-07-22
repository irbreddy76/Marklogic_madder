module namespace rel = "http://marklogic.com/search/relationship";
import module namespace sem = "http://marklogic.com/semantics" 
      at "/MarkLogic/semantics.xqy";

(: Enumerated values :)
declare variable $TRACE_LEVEL_TRACE as xs:string := "RELATIONSHIP-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "RELATIONSHIP-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "RELATIONSHIP-FINE";
declare variable $node-map as map:map := map:map();

declare function rel:getCaseRelationshipRDF($caseId as xs:string)
{
  let $_ := (
    fn:trace("getCaseRelationshipRDF -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- CaseId = " || $caseId, $TRACE_LEVEL_DETAIL)
  ) 
 let $iri := sem:iri("http://www.dhr.state.md.us/CaseRelationship/" || $caseId)
 let $store := sem:store((), cts:collection-query($iri))
 (:
 let $graphStore := sem:store((), cts:collection-query("http://marklogic.com/semantics#default-graph"))
 let $rules := sem:ruleset-store(("rdfs.rules", "subClassOf.rules"), ($store, $graphStore))
 :)
 let $bindings := map:new(map:entry("caseIRI", $iri))
 let $query := "
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
  PREFIX owl: <http://www.w3.org/2002/07/owl#> 
  PREFIX dct: <http://purl.org/dc/terms/> 
  PREFIX mdr: <http://www.dhr.state.md.us/ontology/personCaseRelationships#> 
  CONSTRUCT { 
    ?person ?reltype ?otherperson ; mdr:inCase ?caseIRI. 
    ?caseIRI mdr:isCentralMember ?isCentralMember .
  } WHERE { 
    ?person rdf:type mdr:Person ; ?reltype ?otherperson ; mdr:inCase ?caseIRI.
    ?otherperson rdf:type mdr:Person . 
    OPTIONAL {?caseIRI mdr:centralMember ?centralMember .} 
    BIND (?centralMember=?person AS ?isCentralMember) 
  } "
 let $sparql := sem:sparql($query, $bindings, (), $store)
 return xdmp:to-json(sem:rdf-serialize($sparql, "rdfjson"))
};

declare function rel:getRawPersonRelationship($personId as xs:string)
{
  let $_ := (
    fn:trace("getPersonRelationship -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- PersonId = " || $personId, $TRACE_LEVEL_DETAIL)
  )   
  let $iri := sem:iri("http://www.dhr.state.md.us/Person/" || $personId)
  let $store := sem:store((), cts:collection-query($iri))
  let $ontologyStore := sem:store((), cts:collection-query("Ontology")) 
  let $rules := sem:ruleset-store(("rdfs.rules", "subClassOf.rules"), ($store, $ontologyStore))
  let $bindings := map:new(map:entry("personIRI", $iri))
  let $describe-person-subject := "DESCRIBE ?personIRI WHERE {OPTIONAL{?personIRI ?p2 ?o2 .}}"
  let $describe-person-object := "DESCRIBE ?s1 WHERE {OPTIONAL{?s1 ?p1 ?personIRI .}}"
  let $sparql-person-subject  := sem:sparql($describe-person-subject, $bindings, (), $rules)
  let $sparql-person-object   := sem:sparql($describe-person-object, $bindings, (), $rules)
  return ($sparql-person-subject, $sparql-person-object)
  (:
  let $data := ($sparql-person-subject, $sparql-person-object)
  return sem:rdf-serialize($data, "rdfjson")
  :)
};

declare function rel:getCaseRelationship($caseId as xs:string)
{
  let $_ := (
    fn:trace("getCaseRelationship -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(" -- CaseId = " || $caseId, $TRACE_LEVEL_DETAIL)
  ) 
 let $iri := sem:iri("http://www.dhr.state.md.us/ServiceCase/" || $caseId)
 let $store := sem:store((), cts:collection-query($iri))
 let $graphStore := sem:store((), cts:collection-query("http://marklogic.com/semantics#default-graph"))
 let $rules := sem:ruleset-store(("rdfs.rules", "subClassOf.rules"), ($store, $graphStore))
 let $bindings := map:new(map:entry("caseIRI", $iri))
 let $query := "
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
  PREFIX owl: <http://www.w3.org/2002/07/owl#> 
  PREFIX dct: <http://purl.org/dc/terms/> 
  PREFIX mdr: <http://www.dhr.state.md.us/ontology/personCaseRelationships#> 
  SELECT ?person ?reltype ?otherperson WHERE { 
    ?caseIRI rdf:type mdr:Case; 
             mdr:caseRelationship ?rels . 
    ?rels mdr:relationshipMember ?person . 
    ?person rdf:type mdr:Person ; ?reltype ?otherperson .
    ?otherperson rdf:type mdr:Person . 
  }"
 return sem:sparql($query, $bindings, (), $rules)
};

(: Helpers to get viz related nodes and edges :)
declare function rel:get-distinct-resources($triples as element(sem:triples)) as xs:string* {
  let $nodes :=
    for $so in $triples/sem:triple
    order by $so/sem:subject/fn:string()
    return
      ($so/sem:subject/fn:string(), $so/sem:object/fn:string())
  return fn:distinct-values($nodes)
};

declare function rel:get-viz-nodes($triples as element(sem:triples)) as object-node()* {
  let $distinct := rel:get-distinct-resources($triples)
  for $node at $i in $distinct
  let $id := 
    if (fn:contains($node, "#")) then
      $i cast as xs:string
    else
      fn:tokenize($node, "/")[fn:last()]
  let $label :=
    if (fn:contains($node, "#")) then
      fn:tokenize($node, "#")[fn:last()]
    else
      let $tox := fn:tokenize($node, "/")
      return fn:string-join(($tox[4], $tox[5]), "_")
  let $obj :=
    object-node{"id": $id, "label": $label}
  let $put := map:put($node-map, $label, $id)
  return
    $obj
};

declare function rel:get-viz-edges($triples as element(sem:triples)) as object-node()* {
  for $so in $triples/sem:triple
  let $from := fn:tokenize($so/sem:subject, "/")[fn:last()]
  let $to := 
    if (fn:contains($so/sem:object, "#")) then
      map:get($node-map, fn:tokenize($so/sem:object, "#")[fn:last()])
    else
      fn:tokenize($so/sem:object, "/")[fn:last()]
  let $label := fn:tokenize($so/sem:predicate, "#")[fn:last()]
  return
    object-node{"from": $from, "to": $to, "label": $label}
};

(: To get viz nodes and edges pass $format = "json-viz") :)
(: To get rdf xml document pass $format = "rdfxml") :)
(: To get triple xml document pass $format = "triplexml") :)
(: default format is rdf JSON :)
declare function rel:getPersonRelationship($personId as xs:string, $format as xs:string)
{
  let $data := rel:getRawPersonRelationship($personId)
  return 
    if ($format eq "rdfxml") then 
      document{sem:rdf-serialize($data, $format)}
    else if ($format eq "triplexml") then
      document{sem:rdf-serialize($data, "triplexml")}
  else if ($format eq "json-viz") then
    let $include-rdf-type := fn:false()
    let $triples := sem:rdf-serialize($data, "triplexml")
    let $nodes := rel:get-viz-nodes($triples)
    let $edges := rel:get-viz-edges($triples)
    return
      xdmp:to-json(object-node{
        "nodes": array-node{for $obj in $nodes where $obj/id[. ne "6"][. ne "7"] return $obj},
        "edges": array-node{for $obj in $edges where $obj/label[fn:not(fn:matches(., "(relationshipMember|knows|member|type)"))] return $obj}
      })
    else
      xdmp:to-json(sem:rdf-serialize($data, "rdfjson"))
};


