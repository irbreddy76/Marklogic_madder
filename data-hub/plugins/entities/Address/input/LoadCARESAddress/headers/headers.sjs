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
    if(identifier.SourceSystem == 'MDCHESSIE') {
      header.SystemIdentifiers.push({chessieId: identifier.SourceKey});
    } else if(identifier.SourceSystem == 'CIS') {
      header.SystemIdentifiers.push( {cisId: identifier.SourceKey});
    }
  }
  return header;
}

module.exports = {
  createHeaders: createHeaders
};

