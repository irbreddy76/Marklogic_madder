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
var uri = '/person/ABAWD/' + fn.generateId(envelope) + '.json';

//TODO get CertificationDate from staging data.  This will need to be manually
//added to csv and put in to headers.
var curDate = fn.currentDate().toString().slice(0,7);

xdmp.documentInsert(uri, envelope,
  [xdmp.permission('rest-reader', 'read'),
   xdmp.permission('rest-writer', 'update')],
  ['ABAWD', 'Person', 'Sample', curDate]);
}

module.exports = {
  write: write
};
