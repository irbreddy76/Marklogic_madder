/*
 * Collect IDs plugin
 *
 * @param options - a map containing options. Options are sent from Java
 *
 * @return - an array of ids or uris
 */
function collect(options) {

  return cts.uris(null,null,cts.andQuery([cts.collectionQuery(['LoadABAWDPerson'])]));


  /*
  return cts.uris(null,null,cts.andQuery([cts.collectionQuery(['LoadABAWDPerson']),
                                 cts.orQuery([
                                   cts.jsonPropertyWordQuery("CLIENT_ID", "489000476"),
                                   cts.jsonPropertyWordQuery("CLIENT_ID", "455018525"),
                                   cts.jsonPropertyWordQuery("CLIENT_ID", "449012819")
                                 ])]));
  */
}

module.exports = {
  collect: collect
};
