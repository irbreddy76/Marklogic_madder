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
    var cisId;

    // Get the person's CARES ID which will be used to
    // get related participations.  Assumes
    // a person only has 1 CARES id.
    for(i = 0; i < root.headers.identifiers.length; i++) {
      var id = root.headers.identifiers[i].cisId;
      if(id) {
        cisId = id;
        break; 
      }
    }

    // Participation documents associated with this person's
    // CARES ID
    var participations = cts.search(cts.andQuery([
      cts.collectionQuery('LoadCARESParticipation'),
      cts.jsonPropertyValueQuery('cisId', cisId)
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
          if(participationKey.toString()  == key.toString()) {
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
      cts.collectionQuery(['LoadCARESParticipationDetail']),
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
        Participations: []
      };

      // Now grab all participation entries that match the
      // participation key
      var key = detail.ParticipationIdentifier[0].ParticipationKey;
      for(j = 0; j < participationById.length; j++) {
        var role = participationById[j];
        if(role.key.toString() == key.toString()) {
          partDetail.Participations.push(role.entry);
        }
      }
      participations.push(partDetail);
    }
     
    var addresses = [];
    var addressDocs = cts.search(cts.andQuery([
      cts.collectionQuery(['LoadCARESAddress']),
      cts.jsonPropertyValueQuery('cisId', cisId)
    ])).toArray();
    for(i = 0; i < addressDocs.length; i++) {
      var addressDoc = addressDocs[i].root.content;
      for(j = 0; j < addressDoc.Addresses.length; j++) {
        addresses.push(addressDoc.Addresses[j]);
      }
    }

    return { 
      records: [
      {
        Person: {
          SystemIdentifiers: root.content.SystemIdentifiers,
          PersonName: root.content.PersonName,
          PersonSexCode: root.content.PersonSexCode,
          PersonRaceCode: root.content.PersonRaceCode,
          PersonDigitalImage: root.content.PersonalDigitalImage,
          PersonSSNIdentification: root.content.PersonSSNIdentification,
          PersonBirthDate: root.content.PersonBirthDate,
          Addresses: addresses
        },
        ProgramParticipations: participations
      }]
    }; 
  }
  // for everything else
  else {
    return doc;
  }
}

module.exports = {
  createContent: createContent
};
