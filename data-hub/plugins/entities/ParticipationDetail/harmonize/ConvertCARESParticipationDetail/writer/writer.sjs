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
  var type = fn.normalizeSpace(envelope.content.ParticipationType);
  var uri = '/participation/CARES/' + type.replace(' ', '_') + '/' + fn.generateId(envelope) + '.json';

  xdmp.documentInsert(uri, envelope, 
    [xdmp.permission('rest-reader', 'read'),
     xdmp.permission('rest-writer', 'update'),
     xdmp.permission('mddhr-read', 'read'),
     xdmp.permission('mddhr-write', 'update')], 
    ['CARES', 'ParticipationDetail', 'Sample', type]);
}

module.exports = {
  write: write
};

