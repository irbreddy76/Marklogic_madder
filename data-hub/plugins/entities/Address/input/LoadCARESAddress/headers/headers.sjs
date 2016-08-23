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
    SystemIdentifiers: []
  };
  var i;
  for(i = 0; i < content.SystemIdentifiers.length; i++) {
    var identifier = content.SystemIdentifiers[i];
    var value = {};
    
    if(identifier.ExtractDateTime) {
      value.SourceExtractDateTime = new Date(identifier.ExtractDateTime.replace(' ', 'T'));
    }
    
    if(identifier.SourceSystem == 'MDCHESSIE') {
      value.chessieId = identifier.SourceKey;
      header.SystemIdentifiers.push(value);
    } else if(identifier.SourceSystem == 'CIS') {
      value.cisId = identifier.SourceKey;
      header.SystemIdentifiers.push(value);
    }
  }
  return header;
}

module.exports = {
  createHeaders: createHeaders
};

