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
    relationshipParticipationIds: [],
	//relationshipParticipationTypes: []
  };
  
  for(var i = 0; i < content.Relationships.length; i++) {
	var relationshipIdentifier = content.Relationships[i];
	for(var j=0; j < relationshipIdentifier.ParticipationIdentifier.length; j++) {
		var identifier = relationshipIdentifier.ParticipationIdentifier[j];
		header.relationshipParticipationIds.push({participationId: identifier.ParticipationKey});
		//header.relationshipParticipationTypes.push({relationshipParticipationType: identifier.ParticipationType});
	}
  }
  return header;
}

module.exports = {
  createHeaders: createHeaders
};

