module namespace rel = "http://marklogic.com/search/relationship";
import module namespace sem = "http://marklogic.com/semantics" 
      at "/MarkLogic/semantics.xqy";

(: Enumerated values :)
declare variable $TRACE_LEVEL_TRACE as xs:string := "RELATIONSHIP-TRACE";
declare variable $TRACE_LEVEL_DETAIL as xs:string := "RELATIONSHIP-DETAIL";
declare variable $TRACE_LEVEL_FINE as xs:string := "RELATIONSHIP-FINE";

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
 return sem:rdf-serialize($sparql, "rdfjson")
};

declare function rel:getPersonRelationship($personId as xs:string)
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
  let $data := ($sparql-person-subject, $sparql-person-object)
  return sem:rdf-serialize($data, "rdfjson")
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


