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
function createTriples(id, content, headers, options) {
  //return [];
  var triples = []
  
  for(var i = 0; i < content.Relationships.length; i++) {
	var relationshipIdentifier = content.Relationships[i];
	for(var j=0; j < relationshipIdentifier.Relations.length; j++) {
		var identifier = relationshipIdentifier.Relations[j];
		var relationSubject = identifier.RelationSubject;
		var relationPredicate = identifier.RelationRole;
		var relationObject = identifier.RelationSubject;
		var relationSubjectPrefix = "http://www.dhr.state.md.us/ServiceCase/";
		var relationPredicatePrefix = "http://www.dhr.state.md.us/ontology/personCaseRelationships#";
		var relationObjectPrefix = "http://www.dhr.state.md.us/Person/";
		// construct triples using ontology
		var triple = sem.triple(sem.iri(relationSubjectPrefix.concat(relationSubject)), 
			sem.iri(relationPredicatePrefix.concat(relationPredicate)), relationObjectPrefix.concat(relationObject));
		triples.push(triple);
	}
  }
  
  return triples;  
}

module.exports = {
  createTriples: createTriples
};

