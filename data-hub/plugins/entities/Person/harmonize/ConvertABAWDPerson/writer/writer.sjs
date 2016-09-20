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
var headers = envelope.headers;
var content = envelope.content;

//TODO get CertificationDate from staging data.  This will need to be manually
//added to csv and put in to headers.
//var curDate = fn.currentDate().toString().slice(0,7);
var curDate = headers.currentCertificationPeriod.toString().substr(0,7);

var clientId, i;
for(i = 0; i < headers.SystemIdentifiers.length; i++) {
  var currentIdentifier = headers.SystemIdentifiers[i];
  if(currentIdentifier.ClientID) {
    clientId = currentIdentifier.ClientID;
    break;
  }
}

//var uri = '/person/ABAWD/' + xdmp.hash32(clientId + content.PersonBirthDate) + '/' + 
//  headers.certificationDate + '/person.json';
var uri = '/person/ABAWD/' + xdmp.hash32(clientId + content.PersonBirthDate) + '/person.json';

/*
var previousDocs = cts.uris(null, null, cts.andQuery([
  cts.collectionQuery(['ABAWD']),
  cts.collectionQuery(['Person']),
  cts.collectionQuery(['Active']),
  cts.jsonPropertyValueQuery('ClientID', [clientId]),
  cts.jsonPropertyValueQuery('PersonBirthDate', [content.PersonBirthDate])
]));

for(i = 0; i < previousDocs.length; i++) {
  var currentDoc = prviousDocs[i];
  // Move any previous version to historical.  
  // If uri matches assume it is a reload of existing data.
  if(currentDoc != uri) {
    xdmp.documentAddCollections(currentDoc, 'Inactive'),
    xdmp.documentRemoveCollections(currentDoc, 'Active')
  }
}
*/

if(fn.docAvailable(uri)) {
  var currentDoc = fn.doc(uri);
  currentDoc.triples = currentDoc.triples.concat(envelope.triples);
  if(envelope.headers.currentCertificationPeriod >= currentDoc.headers.currentCertificationPeriod) {
    currentDoc.headers = envelope.headers;
  }
  
  currentDoc.content.Person = envelope.content.Person.concat(currentDoc.content.Person);
  currentDoc.content.Income = envelope.content.Income.concat(currentDoc.content.Income);
  
  // Update Record
  xdmp.documentInsert(uri, currentDoc,
    [xdmp.permission('rest-reader', 'read'),
     xdmp.permission('rest-writer', 'update')],
    ['ABAWD', 'Person', 'Sample', 'Active', curDate]);
} else {
// Create new record
xdmp.documentInsert(uri, envelope,
    [xdmp.permission('rest-reader', 'read'),
     xdmp.permission('rest-writer', 'update')],
    ['ABAWD', 'Person', 'Sample', 'Active', curDate]);
}
}
module.exports = {
  write: write
};
