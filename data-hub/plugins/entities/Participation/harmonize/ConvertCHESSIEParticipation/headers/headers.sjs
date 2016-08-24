/*
 * Create Headers Plugin
 *
 * @param id       - the identifier returned by the collector
 * @param content  - the output of your content plugin
 * @param options  - an object containing options. Options are sent from Java
 *
 * @return - an object of headers
 */
function createHeaders(id, content, options) {
  var header = {
    identifiers: [],
    participationIds: []
  };
  
  var i, j, k;
  for(i = 0; i < content.SystemIdentifiers.length; i++) {
    var identifier = content.SystemIdentifiers[i];
    var value = {};
    
    if(identifier.ExtractDateTime) {
      value.SourceExtractDateTime = new Date(identifier.ExtractDateTime.replace(' ', 'T'));
    }
    
    if(identifier.SourceSystem == 'MDCHESSIE') {
      value.chessieId = identifier.SourceKey;
      header.identifiers.push(value);
    } else if(identifier.SourceSystem == 'CIS') {
      value.cisId = identifier.SourceKey;
      header.identifiers.push(value);
    }
  }

  for(i = 0; i < content.Participation.length; i++) {
    var participation = content.Participation[i];
    for(j = 0; j < participation.ParticipationIdentifier.length; j++) {
      var identifier = participation.ParticipationIdentifier[j];
      var idFound = false;
      for(k = 0; k < header.participationIds.length; k++) {
        if(identifier.ParticipationKey ===
          header.participationIds[k].participationKey) {
          idFound = true;
          break;
        } 
      }
      if(idFound === false) {
        header.participationIds.push({participationId: identifier.ParticipationKey});
      }
    }
  }

  header.RecordType = 'Participation';

  return header;
}

module.exports = {
  createHeaders: createHeaders
};
