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
    var participation = root.content;  
    var participationIdQueries := [];
    
    var i;
    for(i = 0; i < root.content.ParticipationIdentifier.length; i++) {
      var currentIdentifier = root.content.ParticipationIdentifier[i];
      participationIdQueries.push(
        cts.jsonPropertyValueQuery(currentIdentifier.ParticipationType,
          currentIdentifier.ParticipationKey)
      );
    }
    
    var details = [];
    if(participationIdQueries.length > 0) {
      var participationDetail = cts.search(cts.andQuery([
        cts.collectionQuery(['LoadCHESSIEParticipationDetail']),
        participationIdQueries
      ])).toArray();
      
      // Should be only 1
      for(i = 0; i < participationDetail.length; i++) {
        var detail = participationDetails[i].root.content;
        var partDetail = {
          ParticipationProgramName: detail.ParticipationProgramName,
          ParticipationType: detail.ParticipationType,
          OpenDate: detail.OpenDate,
          CloseDate: detail.CloseDate,
          CloseCode: detail.CloseCode
        };
        
        details.push(partDetail);
      }
    }
  
    return { participation: participation, details: details };
  }
  // for everything else
  else {
    return doc;
  }
}

module.exports = {
  createContent: createContent
};
