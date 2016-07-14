/*
 * Create Triples Plugin
 *
 * @param id       - the identifier returned by the collector
 * @param content  - the output of your content plugin
 * @param headers  - the output of your heaaders plugin
 * @param options  - an object containing options. Options are sent from Java
 *
 * @return - an array of triples
 */
var sem = require("/MarkLogic/semantics.xqy");
function createTriples(id, content, headers, options) {
  var triples = {};
  
  for(var i = 0; i < content.Relationships.length; i++) {
	var identifier = content.Relationships[i];
  var subjects = [];
  var relationships = [];
	var members = [];

	var caseId = identifier.ParticipationIdentifier.ParticipationKey;
	var centralMember = identifier.CentralPerson;
	var member;
	for (var j=0; j < identifier.Relations.length; j++) {
		var relationIdentifier = identifier.Relations[j];
    subjects.push(relationIdentifier.RelationSubject);
    relationships.push(getRelationshipProperty(relationIdentifier.RelationRole));
		members.push(relationIdentifier.RelationTarget);
	};
    triples = getTriples(caseId, centralMember, subjects, relationships, members)
  }
  
  return triples;  
}

function getTriples(caseId, centralMember, subjects, relationships, members)
{
    var triples = {};
    var prefixes = {
      "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "mdr": "http://www.dhr.state.md.us/ontology/personCaseRelationships#"
    };
    var fac = sem.rdfBuilder(prefixes);
    var serviceCase = {
      subject: sem.iri("http://www.dhr.state.md.us/ServiceCase/" + caseId), 
      rdfType: sem.iri("http://www.dhr.state.md.us/ontology/personCaseRelationships#Case"),
      caseRelationship: sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + caseId)
    };
    var caseRelationships = {
      subject: sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + caseId),
      self: sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + centralMember),
      rdfType: sem.iri("http://www.dhr.state.md.us/ontology/personCaseRelationships#CaseRelationship"),
      centralMember: sem.iri("http://www.dhr.state.md.us/Person/" + centralMember)
    };
    var serviceCaseTriples = [
      xdmp.apply(fac, serviceCase.subject, "rdf:type", serviceCase.rdfType),
      xdmp.apply(fac, serviceCase.subject, "mdr:caseRelationship", serviceCase.caseRelationship)
    ];
    var caseRelationshipsTriples = [
      xdmp.apply(fac, caseRelationships.subject, "rdf:type", caseRelationships.rdfType),
      xdmp.apply(fac, caseRelationships.subject, "mdr:centralMember", caseRelationships.centralMember),
      xdmp.apply(fac, caseRelationships.self, "mdr:self", caseRelationships.centralMember)
    ]
    for (var i = 0, len = members.length; i < len; i++) {
      caseRelationshipsTriples.push(
        xdmp.apply(fac, 
                   sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + subjects[i]), 
                   "mdr:" + relationships[i], 
                   sem.iri("http://www.dhr.state.md.us/Person/" + members[i]))
      );
    }
    triples['serviceCaseTriples'] = serviceCaseTriples;
    triples['caseRelationshipsTriples'] = caseRelationshipsTriples;
  	return triples;
};

function getRelationshipProperty(relationship)
{
	var propertyLabel = rdf.langString(relationship, "en");
	var store = sem.store([], cts.collectionQuery("Ontology"));
	var bindings = {"propertyLabel": propertyLabel};
	var query = "\
  		PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
  		PREFIX dct: <http://purl.org/dc/terms/> \
  	SELECT ?property WHERE {?s dct:description ?propertyLabel; rdfs:label ?property .} \
	";
	var sparql = sem.sparql(query, bindings, [], store);
	return sparql.next().value.property;
}


module.exports = {
  createTriples: createTriples
};

