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
  var distinctMembers = [];

	var caseId = identifier.ParticipationIdentifier.ParticipationKey;
	var centralMember = identifier.CentralPerson;
  distinctMembers = getDistinctMembers(identifier.Relations)   
  triples = getTriples(caseId, centralMember, identifier.Relations, distinctMembers);
  return triples;  
  }
};

function getTriples(caseId, centralMember, relationships, members)
{
    var triples = {};
    var prefixes = {
      "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "mdr": "http://www.dhr.state.md.us/ontology/personCaseRelationships#"
    };
    var fac = sem.rdfBuilder(prefixes);
    var namedGraphIRIs = [];
    var serviceCase = {
      subject: sem.iri("http://www.dhr.state.md.us/ServiceCase/" + caseId), 
      rdfType: sem.iri("http://www.dhr.state.md.us/ontology/personCaseRelationships#Case"),
      caseRelationship: sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + caseId)
    };
    var caseRelationships = {
      subject: sem.iri("http://www.dhr.state.md.us/CaseRelationship/" + caseId),
      rdfType: sem.iri("http://www.dhr.state.md.us/ontology/personCaseRelationships#CaseRelationship"),
      centralMember: sem.iri("http://www.dhr.state.md.us/Person/" + centralMember)
    };
    var serviceCaseTriples = [
      xdmp.apply(fac, serviceCase.subject, "rdf:type", serviceCase.rdfType),
      xdmp.apply(fac, serviceCase.subject, "mdr:caseRelationship", serviceCase.caseRelationship)
    ];
    namedGraphIRIs.push(serviceCase.subject),
    namedGraphIRIs.push(fn.replace(serviceCase.subject, "\\d+", ""))
    var caseRelationshipsTriples = [
      xdmp.apply(fac, caseRelationships.subject, "rdf:type", caseRelationships.rdfType),
      xdmp.apply(fac, caseRelationships.subject, "mdr:centralMember", caseRelationships.centralMember)
    ];
    namedGraphIRIs.push(caseRelationships.subject);
    namedGraphIRIs.push(fn.replace(caseRelationships.subject, "\\d+", ""));
    var personTriples = [];
    for (var i = 0, len = members.length; i < len; i++) {
      caseRelationshipsTriples.push(
        xdmp.apply(fac, caseRelationships.subject, "mdr:relationshipMember", sem.iri("http://www.dhr.state.md.us/Person/" + members[i]))
      );
      namedGraphIRIs.push("http://www.dhr.state.md.us/Person/" + members[i]);
      namedGraphIRIs.push("http://www.dhr.state.md.us/Person/");
      personTriples.push(
        xdmp.apply(fac, sem.iri("http://www.dhr.state.md.us/Person/" + members[i]), "rdf:type", sem.iri("http://www.dhr.state.md.us/ontology/personCaseRelationships#Person")),
        xdmp.apply(fac, sem.iri("http://www.dhr.state.md.us/Person/" + members[i]), "mdr:inCase", caseRelationships.subject)
      );      
    }
    for (var i = 0, len = relationships.length; i < len; i++) {
      var subjIRI = sem.iri("http://www.dhr.state.md.us/Person/" + relationships[i].RelationSubject);
      var predCURIE = "mdr:" + getPropertyFromLabel(relationships[i].RelationRole);
      var objIRI = sem.iri("http://www.dhr.state.md.us/Person/" + relationships[i].RelationTarget);
      personTriples.push(
        xdmp.apply(fac, subjIRI, predCURIE, objIRI)
      );
    }
    triples['serviceCaseTriples'] = serviceCaseTriples;
    triples['caseRelationshipsTriples'] = caseRelationshipsTriples;
    triples['personTriples'] = personTriples;
    triples['namedGraphIRIs'] = fn.distinctValues(xdmp.arrayValues(namedGraphIRIs));
    return triples;
};

function getPropertyFromLabel(label) 
{
  var propertyLabel = rdf.langString(label, "en")
  var store = sem.store([], cts.collectionQuery("LoadOntologyForRelationship"));
  
  var bindings = {"propertyLabel": propertyLabel};
  var query = "\
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \
    PREFIX owl: <http://www.w3.org/2002/07/owl#> \
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
    PREFIX dct: <http://purl.org/dc/terms/> \
    SELECT ?property WHERE {?s rdf:type owl:ObjectProperty; dct:description ?propertyLabel; rdfs:label ?property .}";
  var sparql = sem.sparql(query, bindings, [], store);
  return sparql.next().value.property;
};

function getDistinctMembers(relations)
{
  var distinctMembers = [];
  var memberExists = [];
  for (var j=0; j < relations.length; j++) {
    if (!memberExists[relations[j].RelationSubject])
    {
      distinctMembers.push(relations[j].RelationSubject);
      memberExists[relations[j].RelationSubject] = true
    }
    if (!memberExists[relations[j].RelationTarget])
    {
      distinctMembers.push(relations[j].RelationTarget);
      memberExists[relations[j].RelationTarget] = true
    }       
  };
  return distinctMembers;
};


module.exports = {
  createTriples: createTriples
};

