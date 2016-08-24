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
    
  var participationIdentifiers = [];
  
  var i;
  for(i = 0; i < envelope.content.ParticipationIdentifiers.length; i++) {
    var currentIdentifier = envelope.content.ParticipationIdentifiers[i];
    participationIdentifiers.push(
      cts.jsonPropertyValueQuery(currentIdentifier.ParticipationType, currentIdentifier.ParticipationKey));
  }
  var originalRecord = cts.uris((), (), cts.andQuery([participationIdentifiers,
    cts.collectionQuery(['ParticipationDetail']),
    cts.collectionQuery(['CHESSIE'])]).toArray();
  if(originalRecord.length == 0) {
    var type = fn.normalizeSpace(envelope.content.ParticipationType);
    var uri = '/participation/CHESSIE/' + type.replace(' ', '_') + '/' + fn.generateId(envelope) + '.json';

    envelope.headers.systemModifiedDate = fn.currentDateTime();
    envelope.headers.systemLoadDate = fn.currentDateTime();
    
    xdmp.documentInsert(uri, envelope, 
      [xdmp.permission('mddhr-read', 'read'),
       xdmp.permission('mddhr-write', 'update'),
       xdmp.permission('mddhr-CHESSIE', 'read'),
       xdmp.permission('mddhr-CHESSIE', 'update')], 
      ['CHESSIE', 'ParticipationDetail', 'Sample', type]);
  } else {
    var original = fn.doc(originalRecord[0]);
    envelope.headers.systemModifiedDate = fn.currentDateTime();
    envelope.headers.systemLoadDate = original.headers.systemLoadDate;
    xdmp.documentInsert(fn.document-uri(originalRecord[0], envelope,
      xdmp.documentGetPermissions(originalRecord[0]), xdmp.documentGetCollections(originalRecord[0]));
  }
}

module.exports = {
  write: write
};

