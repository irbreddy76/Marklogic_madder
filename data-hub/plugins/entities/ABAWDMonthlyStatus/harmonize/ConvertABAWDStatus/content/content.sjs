/*
 * Create Content Plugin
 *
 * @param id         - the identifier returned by the collector
 * @param options    - an object containing options. Options are sent from Java
 *
 * @return - your content
 */
function createContent(id, options) {
  var doc = cts.doc(id);
  var root = doc.root;

  // Mark record as processed so it doesn't get picked up on subsequent runs
  //xdmp.documentAddCollections(id, 'processed');

  //Build a list of annotations that the writer will create
  var birthDate = new Date(root.content.DOB);
  var annotations = [];
  var identifiers = [];

  //build identifiers used for all annotations
  identifiers.push({ name: 'ClientID', value: root.content.ClientID });
  identifiers.push({ name: 'AUNum', value: root.content.AUNum });

  //Create annotation for every property that is a date
  for(var propt in root.content){
    if(isDate(propt) && root.content.hasOwnProperty(propt) && root.content[propt] != "") {
      var aDate = new Date(propt);
      var aDateStr = createXsDate(aDate);
      annotations.push({
        annotationDateTime: aDateStr,
        identifiers: identifiers,
        properties: [
          {"name": "customerName", "value": root.content.FirstName + " " + root.content.LastName},
          {"name": "customerDoB", "value": birthDate.toISOString().split('T')[0]},
          {"name": "annotationType", "value": 'ABAWDAction'},
          {"name": "abawdAction", "value": root.content[propt].toString()}
        ]
      })
    }
  }

  //Build screening annotation
  var screenDate = new Date(root.content.ScreeningDate);
  var screenDateStr = createXsDate(screenDate);
  var screeningAnnotation = {
    annotationDateTime: screenDateStr,
    identifiers: identifiers,
    properties: [
      {"name": "customerName", "value": root.content.FirstName + " " + root.content.LastName},
      {"name": "customerDoB", "value": birthDate.toISOString().split('T')[0]},
      {"name": "actualScreeningResult", "value": root.content.ScreeningResult.toString()},
      {"name": "annotationType", "value": 'ABAWDStatus'}
    ]
  };

  annotations.push(screeningAnnotation);

  return annotations;
}

function isDate(val) {
    var d = new Date(val);
    return !isNaN(d.valueOf());
}

function createXsDate(date) {
  var dateString =
  date.getFullYear() + "-" + (date.getMonth() + 1)
  + "-" + date.getDate() + "T" + date.getHours()
  + ":" + date.getMinutes() + ":" + date.getSeconds()
  + "+" + (date.getTimezoneOffset() / 60) + ":00"

  return dateString;
}

module.exports = {
  createContent: createContent
};
