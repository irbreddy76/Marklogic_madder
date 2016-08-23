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
    var value = {};
    if(identifier.ExtractDateTime) {
      value.SourceExtractDateTime = new Date(identifier.ExtractDateTime.replace(' ', 'T'));
    }
    if(identifier.ParticipationType == 'Service Case') {
      value.ServiceCaseId = identifier.ParticipationKey;
      header.ParticipationIds.push(value);
      header.CaseType = 'Service Case';
    } else if(identifier.ParticipationType ==  'Adoption Planning') {
      value.AdoptionPlanningId = identifier.ParticipationKey;
      header.ParticipationIds.push(value);
      header.CaseType = 'Adoption Planning';
    }
  }

  header.status = content.OpenDate;  

  return header;
}

module.exports = {
  createHeaders: createHeaders
};
