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

  var identifiers = [];
  
  var i;
  
  for(i = 0; i < envelope.content.SystemIdentifiers.length; i++) {
    var currentIdentifier = envelope.content.SystemIdentifiers[i];
    identifiers.push(
      cts.jsonPropertyValueQuery(currentIdentifier.SourceSystem, currentIdentifier.SourceKey));
  }
  
  var originalRecord = cts.uris((), (), cts.andQuery([identifiers,
    cts.collectionQuery(['Person']),
    cts.collectionQuery(['CHESSIE'])]).toArray();
  
  if(originalRecord.length == 0) {   
    var uri = '/person/CHESSIE/' + fn.generateId(envelope) + '.json';

    envelope.header.systemModifiedDate = fn.currentDateTime();
    envelope.header.systemLoadDate = fn.currentDateTime();

    xdmp.documentInsert(uri, envelope, 
      [xdmp.permission('mddhr-read', 'read'),
       xdmp.permission('mddhr-write', 'update'),
       xdmp:permission('mddhr-CHESSIE' 'read'),
       xdmp:permission('mddhr-CHESSIE' 'update')],
      ['CHESSIE', 'Person', 'Sample']);
  } else {
     let doc = fn.doc(originalRecord[0]);
     envelope.header.systemModifiedDate = fn.currentDateTime();
     envelope.header.systemLoadDate = doc.headers.systemLoadDate;
     xdmp.documentInsert(originalRecord[0], envelope,
       xdmp.documentGetPermissions(originalRecord[0]), xdmp.documentGetCollections(originalRecord[0]));
  }
}

module.exports = {
  write: write
};

