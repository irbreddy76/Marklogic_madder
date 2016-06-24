/*
 * Create Content Plugin
 *
 * @param id         - the identifier returned by the collector
 * @param options    - an object containing options. Options are sent from Java
 *
 * @return - your content
 */
function createContent(id, options) {
  var doc = cts.doc(id);
  var root = doc.root;

  // for xml we need to use xpath
  if (root && xdmp.nodeKind(root) === 'element') {
    return root.xpath('/*:envelope/*:content/node()');
  }
  // for json we need to return the content
  else if (root && root.content) {
    var i, j, k;
    var chessieId;

    // Get the person's chessie ID which will be used to
    // get related participations.  Assumes
    // a person only has 1 chessie id.
    for(i = 0; i < root.headers.identifiers.length; i++) {
      var id = root.headers.identifiers[i].chessieId;
      if(id) {
        chessieId = id;
        break; 
      }
    }

    // Participation documents associated with this person's
    // CHESSIE ID
    var participations = cts.search(cts.andQuery([
      cts.collectionQuery('CHESSIEParticipation'),
      cts.jsonPropertyValueQuery('chessieId', chessieId)
    ])).toArray();
 
    var participationById = []; 
    var participationIds = [];

    // parse each participation document
    for(i = 0; i < participations.length; i++) {
      var participationDoc = participations[i].root.content;

      // sort participation entries in the participation document
      // by participation key.  Assumes each participation has
      // a single participation key.
      for(j = 0; j < participationDoc.Participation.length; j++) {
        var participationEntry = participationDoc.Participation[j];
        var key = participationEntry.ParticipationIdentifier[0].ParticipationKey;
        participationById.push({ key: key, entry: participationEntry });

        // Build list of ParticipationIds to fetch participation details.
        var keyFound = false;
        for(k = 0; k < participationIds.length; k++) {
          var participationKey = participationIds[k];
          if(participationKey === key) {
            keyFound = true;
            break;
          }
        }
        if(keyFound === false) {
          participationIds.push(key);
        }
      }
    }

    var participations = [];
    var participationDetails = cts.search(cts.andQuery([
      cts.collectionQuery(['CHESSIEParticipationDetail']),
      cts.jsonPropertyValueQuery('participationId', participationIds)
    ])).toArray();
    for(i = 0; i < participationDetails.length; i++) {
      var detail = participationDetails[i].root.content;
      var partDetail = {
        ParticipationIdentifiers: detail.ParticipationIdentifier,
        ParticipationProgramName: detail.ParticipationProgramName,
        ParticipationType: detail.ParticipationType,
        OpenDate: detail.OpenDate,
        CloseDate: detail.CloseDate,
        CloseCode: detail.CloseCode,
        PersonRoles: []
      };

      // Now grab all participation entries that match the
      // participation key
      var key = detail.ParticipationIdentifier[0].ParticipationKey;
      for(j = 0; j < participationById.length; j++) {
        var role = participationById[j];
        if(role.key.toString() == key.toString()) {
          partDetail.PersonRoles.push(role.entry);
        }
      }
      participations.push(partDetail);
    }
     
    var addresses = [];
    var addressDocs = cts.search(cts.andQuery([
      cts.collectionQuery(['CHESSIEAddress']),
      cts.jsonPropertyValueQuery('chessieId', chessieId)
    ])).toArray();
    for(i = 0; i < addressDocs.length; i++) {
      var addressDoc = addressDocs[i].root.content;
      for(j = 0; j < addressDoc.Addresses.length; j++) {
        addresses.push(addressDoc.Addresses[j]);
      }
    }

    return { 
      Person: {
        SystemIdentifiers: root.content.SystemIdentifiers,
        PersonName: root.content.PersonName,
        PersonSexCode: root.content.PersonSexCode,
        PersonRaceCode: root.content.PersonRaceCode,
        PersonDigitalImage: root.content.PersonalDigitalImage,
        PersonSSNIdentification: root.content.PersonSSNIdentification,
        Addresses: addresses
      },
      Participations: participations
    } 
      
  }
  // for everything else
  else {
    return doc;
  }
}

module.exports = {
  createContent: createContent
};
