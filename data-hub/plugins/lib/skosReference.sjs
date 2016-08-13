/*
 * SKOS - Reference data lookup
 *
 * @param system - the system identifier; for example 'ABAWD'
 * @param scheme - the scheme identifier; for example 'DisabilityTypes'
 *                   - 'PrimaryLanguageCodes', 'INSStatus'
 *                   - 'UnearnedIncomeCodes', 'UnearnedIncomeFrequency'
 * @param shortCode  - the supported code for each of the scheme
 *                   - for example DisabilityTypes codes are A,B.C.D..,P,R,S,T,U
 *                   - for example INSStatus codes are AA,AS,CL,NP,NR,NS,NT,RF,ST,TR,PR
 *                   - for example PrimaryLanguageCodes are A,L,E,F,O,P,G,R,H,S,I,V,K,Z,X
 *                   - for example UnEarnedIncomeCodes are BL,SI,FP,RB,IP
 *                   - for example UnearnedIncomeFrequency are AC,AN,BM,BW,OT
 *
 * @return - the prefered label for the provided code
 */
function getLabelFromCode(system, scheme, shortCode) 
{
  var store = sem.store([], cts.collectionQuery("http://www.dhr.state.md.us/conceptschemes/" + system));
  var bindings = {
	"inScheme": sem.iri("http://www.dhr.state.md.us/conceptschemes/" + system + "/" + scheme), 
	"code": sem.typedLiteral(shortCode, sem.iri("http://www.w3.org/2001/XMLSchema/string"))
  };
  var query = '\
	PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \
	PREFIX owl: <http://www.w3.org/2002/07/owl#> \
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
	PREFIX dct: <http://purl.org/dc/terms/> \
	PREFIX skos: <http://www.w3.org/2004/02/skos/core#> \
	PREFIX xs: <http://www.w3.org/2001/XMLSchema/> \
	SELECT ?concept ?prefLabel WHERE {?concept skos:prefLabel ?prefLabel ; skos:notation ?code ; skos:inScheme ?inScheme . } \
  ';
  var sparql = sem.sparql(query, bindings, [], store);
  return sparql.next().value.prefLabel.toString();
  //return sparql.next().value; //.prefLabel.toString();
};
/*
 * SKOS - Reference data lookup
 *
 * @param system - the system identifier; for example 'ABAWD'
 * @param scheme - the scheme identifier; for example 'DisabilityTypes'
 *                   - 'PrimaryLanguageCodes', 'INSStatus'
 *                   - 'UnearnedIncomeCodes', 'UnearnedIncomeFrequency'
 *
 * @return - the short code and prefered label for the provided scheme
 */
function getAllLabels(system, scheme) 
{
  var store = sem.store([], cts.collectionQuery("http://www.dhr.state.md.us/conceptschemes/" + system));
  var bindings = {
	"inScheme": sem.iri("http://www.dhr.state.md.us/conceptschemes/" + system + "/" + scheme)
  };
  var query = '\
	PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \
	PREFIX owl: <http://www.w3.org/2002/07/owl#> \
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
	PREFIX dct: <http://purl.org/dc/terms/> \
	PREFIX skos: <http://www.w3.org/2004/02/skos/core#> \
	PREFIX xs: <http://www.w3.org/2001/XMLSchema/> \
	SELECT ?concept ?prefLabel WHERE {?concept skos:prefLabel ?prefLabel; \
	skos:inScheme ?inScheme . } \
  ';
  var sparql = sem.sparql(query, bindings, [], store);
  return sparql;
};

exports.getLabelFromCode = getLabelFromCode;
exports.getAllLabels = getAllLabels;