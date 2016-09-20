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
  //var certificationPeriod;
  
  //if(options.certificationPeriod) {
  //  certificationPeriod = options.certificationPeriod;
  //} else {
  //  certificationPeriod = fn.currentDate();
  //}
  return {
  // Set certification month here
  // This is used to identify when the record was created
  // and is used to determine which changes take precedence on merge.
  //  certificationPeriod: certificationPeriod
  };
}

module.exports = {
  createHeaders: createHeaders
};

