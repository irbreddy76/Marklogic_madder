/*~
 * Writer Plugin
 *
 * @param id       - the identifier returned by the collector
 * @param envelope - the final envelope
 * @param options  - an object options. Options are sent from Java
 *
 * @return - nothing
 */
function write(id, envelope, options) {
  var uri = '/person/CHESSIE/master-' + fn.generateId(envelope) + '.json';

  xdmp.documentInsert(uri, envelope, 
    [xdmp.permission('rest-reader', 'read'),
     xdmp.permission('rest-writer', 'update'),
     xdmp.permission('mddhr-read', 'read'),
     xdmp.permission('mddhr-write', 'update'),
     xdmp.permission('mddhr-write', 'insert'),
     xdmp.permission('mddhr-CHESSIE', 'read'),
     xdmp.permission('mddhr-CHESSIE', 'update'),
     xdmp.permission('mddhr-CHESSIE', 'insert')],
    ['CHESSIE', 'MasterPerson', 'Sample']);
}

module.exports = {
  write: write
};

