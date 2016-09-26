
var anLib = require("/lib/annotation-lib.xqy");

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

  var content = envelope.content;

  //Loop through array of annotations in content and call library method to create
  for(var annotation in content){
    if(content.hasOwnProperty(annotation)) {
      anLib.createAnnotation(null, content[annotation].identifiers, content[annotation]);
    }
  }
}

module.exports = {
  write: write
};
