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
  identifiers.push({'ClientID': root.content.ClientID });
  identifiers.push({'AUNum': root.content.AUNum });

  //Create annotation for every property that is a date
  for(var propt in root.content){
    if(isDate(propt) && root.content.hasOwnProperty(propt) && root.content[propt] != "") {
      var aDate = new Date(propt);
      var aDateStr = aDate.toISOString().split('T')[0]; //createXsDate(aDate);
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

  //Build screening annotation, if exists
  if(root.content.ScreeningResult && root.content.ScreeningResult != "") {
    var screenDate = new Date(root.content.ScreeningDate);
    var screenDateStr = screenDate.toISOString().split('T')[0]; //createXsDate(screenDate);
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
  }

  return annotations;
}

function isDate(val) {
    var d = new Date(val);
    return !isNaN(d.valueOf());
}

//append a defaul time onto a Date, also convert single digit month and day to double
function createXsDate(date) {
  var day = null;
  var month = null;

  if(date.getDate() < 10) {
    day = "0" + date.getDate();
  } else {
    day = date.getDate();
  }

  if(date.getMonth()+1 < 10) {
    month = "0" + (date.getMonth() + 1);
  } else {
    month = date.getMonth() + 1;
  }

  var dateString =
  date.getFullYear() + "-" + month
  + "-" + day + "T" + date.getHours()
  + ":" + date.getMinutes() + ":" + date.getSeconds()
  + "+" + (date.getTimezoneOffset() / 60) + ":00"

  return dateString;
}

module.exports = {
  createContent: createContent
};
