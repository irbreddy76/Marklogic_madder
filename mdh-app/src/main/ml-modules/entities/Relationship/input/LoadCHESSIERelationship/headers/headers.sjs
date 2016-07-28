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
    participationIds: [],
    centralpersonIds: []
  };
  
  for(var i = 0; i < content.Relationships.length; i++) {
	var identifier = content.Relationships[i];
	header.participationIds.push({participationId: identifier.ParticipationIdentifier.ParticipationKey});
	header.centralpersonIds.push({centralpersonId: identifier.CentralPerson});
  }
  return header;
}

module.exports = {
  createHeaders: createHeaders
};

