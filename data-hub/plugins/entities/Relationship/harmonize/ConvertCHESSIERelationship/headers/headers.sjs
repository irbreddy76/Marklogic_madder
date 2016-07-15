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
    RecordType: 'Relationship',
    ParticipationIds: [],
  };
 
	for(var i = 0; i < content.Relationships.length; i++) {
		var identifier = content.Relationships[i];
		if(identifier.ParticipationIdentifier.ParticipationType == 'Service Case') {
		  header.ParticipationIds.push({ServiceCaseId: identifier.ParticipationIdentifier.ParticipationKey});
		  header.CaseType = 'Service Case';
		} else if(identifier.ParticipationIdentifier.ParticipationType ==  'Adoption Planning') {
		  header.ParticipationIds.push({AdoptionPlanningId: identifier.ParticipationIdentifier.ParticipationKey});
		  header.CaseType = 'Adoption Planning';
		} else if(identifier.ParticipationIdentifier.ParticipationType ==  'AU') {
		  header.ParticipationIds.push({AUId: identifier.ParticipationIdentifier.ParticipationKey});
		  header.CaseType = 'AU';
		}	
	}

  return header;
}

module.exports = {
  createHeaders: createHeaders
};
