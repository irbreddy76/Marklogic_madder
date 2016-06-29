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
    var i, j;
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
        SystemIdentifiers: root.content.SystemIdentifiers,
        PersonName: root.content.PersonName,
        PersonSexCode: root.content.PersonSexCode,
        PersonRaceCode: root.content.PersonRaceCode,
        PersonDigitalImage: root.content.PersonalDigitalImage,
        PersonSSNIdentification: root.content.PersonSSNIdentification,
        PersonBirthDate: root.content.PersonBirthDate,
        Addresses: addresses
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
