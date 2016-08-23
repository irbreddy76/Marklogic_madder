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
    participationIds: []
  };
  
  for(var i = 0; i < content.ParticipationIdentifier.length; i++) {
    var identifier = content.ParticipationIdentifier[i];
    var value = {};
    if(identifier.ExtractDateTime) {
      value.SourceExtractDateTime = new Date(identifier.ExtractDateTime.replace(' ', 'T'));
    }
    value.participationId = identifier.ParticipationKey;
    header.participationIds.push(value);
  }
  return header;
}

module.exports = {
  createHeaders: createHeaders
};

