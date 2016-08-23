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
  
  var systemIdentifiers = [];
  var participationIdentifiers = [];
  
  var i;
  for(i = 0; i < envelope.content.participation.SystemIdentifiers.length; i++) {
    var currentIdentifier = envelope.content.participation.SystemIdentifiers[i];
    systemIdentifiers.push(
      cts.jsonPropertyValueQuery(currentIdentifier.SourceSystem, currentIdentifier.SourceKey));
  }
  for(i = 0; i < envelope.content.participation.ParticipationIdentifiers.length; i++) {
    var currentIdentifier = envelope.content.participation.ParticipationIdentifiers[i];
    participationIdentifiers.push(
      cts.jsonPropertyValueQuery(currentIdentifier.ParticipationType, currentIdentifier.ParticipationKey));
  }
  var originalRecord = cts.uris((), (), cts.andQuery([systemIdentifiers, participationIdentifiers,
    cts.collectionQuery(['Participation']),
    cts.collectionQuery(['CARES'])]).toArray();
  
  if(originalRecord.length == 0) {
    var uri = '/participation/CARES/' + fn.generateId(envelope) + '.json';
    envelope.headers.systemModifiedDate = fn.currentDateTime();
    envelope.headers.systemLoadDate = fn.currentDateTime();

    xdmp.documentInsert(uri, envelope, 
      [xdmp.permission('mddhr-read', 'read'),
       xdmp.permission('mddhr-write', 'update'),
       xdmp:permission('mddhr-CARES' 'read'),
       xdmp:permission('mddhr-CARES' 'update')],
      ['CARES', 'Participation', 'Sample']);
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

