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
  var uri = '/person/CARES/master-' + fn.generateId(envelope) + '.json';

  xdmp.documentInsert(uri, envelope, 
    [xdmp.permission('rest-reader', 'read'),
     xdmp.permission('rest-writer', 'update')],
    ['CARES', 'MasterPerson', 'Sample']);
}

module.exports = {
  write: write
};

