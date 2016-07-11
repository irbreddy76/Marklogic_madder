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
    RecordType: 'Case',
    ParticipationIds: [],
  };
  
  for(var i = 0; i < content.ParticipationIdentifier.length; i++) {
    var identifier = content.ParticipationIdentifier[i];
    if(identifier.ParticipationType == 'Service Case') {
      header.ParticipationIds.push({ServiceCaseId: identifier.ParticipationKey});
      header.CaseType = 'Service Case';
    } else if(identifier.ParticipationType ==  'Adoption Planning') {
      header.ParticipationIds.push({AdoptionPlanningId: identifier.ParticipationKey});
      header.CaseType = 'Adoption Planning';
    } else if(identifier.ParticipationType ==  'AU') {
      header.ParticipationIds.push({AUId: identifier.ParticipationKey});
      header.CaseType = 'AU';
    }	
	
  }

  header.status = content.OpenDate;  

  return header;
}

module.exports = {
  createHeaders: createHeaders
};
