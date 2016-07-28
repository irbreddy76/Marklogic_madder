/*~
 * Writer Plugin
 *
 * @param id       - the identifier returned by the collector
 * @param envelope - the final envelope
 * @param options  - an object options. Options are sent from Java
 *
 * @return - nothing
 */
function write(id, envelope, options) {
	declareUpdate();
	var sem = require("/MarkLogic/semantics.xqy");

	var triples = envelope.triples;
	var final = [];
	xdmp.log("ServiceCase Triples Count:" + triples.serviceCaseTriples.length, "debug");
	xdmp.log("CaseRelationship Triples Count:" + triples.caseRelationshipsTriples.length, "debug");
	xdmp.log("Person Triples Count:" + triples.personTriples.length, "debug");
	xdmp.log("Named Graph IRI Count:" + triples.namedGraphIRIs.length, "debug");
	var graphArray = [];
	for (var j = 0, len = triples.namedGraphIRIs.length; j < len; j++) 
	{
		graphArray.push(triples.namedGraphIRIs[j]);
	}
	for (var i = 0, len = triples.serviceCaseTriples.length; i < len; i++) 
	{ 		
		final.push(sem.triple(triples.serviceCaseTriples[i]));				
	}
	for (var i = 0, len = triples.caseRelationshipsTriples.length; i < len; i++) 
	{ 
		final.push(sem.triple(triples.caseRelationshipsTriples[i]));		
	}
	for (var i = 0, len = triples.personTriples.length; i < len; i++) 
	{ 
		final.push(sem.triple(triples.personTriples[i]));		
	}
	try {
		//sem.rdfInsert(final, [], xdmp.defaultPermissions(), triples.namedGraphIRIs, 0, []);
		//sem.rdfInsert(final, [], xdmp.defaultPermissions(), ["test", "bug"]);
		//sem.rdfInsert(final, [], xdmp.defaultPermissions(), xdmp.toJSON(triples.namedGraphIRIs));
		sem.rdfInsert(final, [], xdmp.defaultPermissions(), graphArray);
		//xdmp.log(triples.namedGraphIRIs);
		//xdmp.log(['iris:', triples.namedGraphIRIs, xdmp.nodeKind(triples.namedGraphIRIs)]);
	}
	catch (e)
	{
		xdmp.log("Error while harmonizing triples:" + e);
	} 
	

}

module.exports = {
  write: write
};

