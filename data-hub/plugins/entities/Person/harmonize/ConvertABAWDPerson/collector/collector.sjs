/*
 * Collect IDs plugin
 *
 * @param options - a map containing options. Options are sent from Java
 *
 * @return - an array of ids or uris
 */
function collect(options) {
  return cts.elementValues(xs.QName("CLIENT_ID"));
}

module.exports = {
  collect: collect
};
