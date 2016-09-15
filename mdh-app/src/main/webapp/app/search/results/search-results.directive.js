(function() {
  'use strict';

  /**
   * angular element directive; displays search results.
   *
   * Binds a `link` property to each result object, based on the result of the function passed to the `link` attribute. If no function is passed a default function is provided. The resulting `link` property will have the form `/detail?uri={{ result.uri }}`
   *
   * attributes:
   *
   * - `search`: a reference to the search results object from {@link MLSearchContext#search}
   * - `link`: optional. a function that accepts a `result` object, and returns a URL to be used as the link target in the search results display
   * - `click`: optional. a function that accepts a `result` object. if present, will be used as the click-handler for each result (`link` will be ignored)
   * - `template`: optional. A URL referencing a template to be used with the directive. If empty, the default bootstrap template will be used.
   *
   * Example:
   *
   * ```
   * <ml-results results="ctrl.response.results" link="ctrl.linkTarget(result)"></ml-results>```
   *
   * @namespace ml-results
   */
  angular.module('app.search')
    .directive('searchResults', searchResults)
    .controller('ResultsController', ResultsController);

  ResultsController.$inject = ['$scope', '$modal', 'MLRest', '$sce', '$http'];

  function searchResults() {
    return {
      restrict: 'E',
      controller: 'ResultsController',
      controllerAs: 'ctrl',
      scope: {
        results: '=',
        click: '&',
        link: '&',
        label: '&',
        toggleSort: '&'
      },
      templateUrl: template,
      link: link
    };
  }

  function template(element, attrs) {
    var url;

    if (attrs.template) {
      url = attrs.template;
    } else {
      url = '/templates/ml-results.html';
    }

    return url;
  }

  function link(scope, element, attrs) {
    scope.shouldClick = !!attrs.click;

    // default link fn
    if ( !attrs.link ) {
      scope.link = function(result) {
        // directive methods require objects
        return '/detail?uri=' + encodeURIComponent( result.result.uri );
      };
    }

    // default label fn
    if ( !attrs.label ) {
      scope.label = function(result) {
        // directive methods require objects
        return _.last( result.result.uri.split('/') );
      };
    }

    scope.$watch('results', function(newVal, oldVal) {
      _.each(newVal, function(result) {
        result.link = scope.link({ result: result });
        result.label = scope.label({ result: result });
      });
    });
  }

  function ResultsController($scope, $modal, MLRest, $sce, $http) {

    $scope.languagePrefs = [
      { label: "en", value: "English (en)" },
      { label: "es", value: "Spanish (es)" },
      { label: "ar", value: "Arabic (ar)" },
      { label: "zh", value: "Chinese (zh)" },
      { label: "fr", value: "French (fr)" },
      { label: "fa", value: "Farsi (fa)" },
      { label: "ru", value: "Russian (ru)" },
      { label: "fa", value: "Farsi (fa)" },
      { label: "hi", value: "Hindi (hi)" },
      { label: "vi", value: "Vietnamese (vi)" },
      { label: "ur", value: "Urdu (ur)" },
      { label: "sw", value: "Swahili (sw)" },
      { label: "ne", value: "Napali (ne)" },
      { label: "rw", value: "Kinyarwanda (rw)" },
      { label: "am", value: "Amharic (am)" }
    ];

    $scope.notificationTypes = [
      { value: "Appointment Notice", label: "Appointment Notice" },
      { value: "Approval Notice", label: "Approval Notice" },
      { value: "Denial Notice", label: "Denial Notice" },
      { value: "1st Month Warning", label: "1st Month Warning" },
      { value: "2nd Month Warning", label: "2nd Month Warning" },
      { value: "Change Notice", label: "Change Notice" },
      { value: "Case Closure Notice - NOAA", label: "Case Closure Notice - NOAA" }
    ];

    $scope.abawdActions = [
        { value: "Pro-rated month", label: "Pro-rated month" },
        { value: "EXEMPT: Over 49", label: "EXEMPT: Over 49" },
        { value: "EXEMPT: Under 18", label: "EXEMPT: Under 18" },
        { value: "EXEMPT: Has child <18", label: "EXEMPT: Has child <18" },
        { value: "EXEMPT: Pregnant", label: "EXEMPT: Pregnant" },
        { value: "EXEMPT:Is disabled", label: "EXEMPT:Is disabled" },
        { value: "EXEMPT: Receives disability payment", label: "EXEMPT: Receives disability payment" },
        { value: "EXEMPT: Applied for Unemployment Insurance", label: "EXEMPT: Applied for Unemployment Insurance" },
        { value: "EXEMPT: Receives Unemployment Insurance", label: "EXEMPT: Receives Unemployment Insurance" },
        { value: "EXEMPT: Employed 20+ hours/week", label: "EXEMPT: Employed 20+ hours/week" },
        { value: "EXEMPT: Self-employed 30+ hours/week", label: "EXEMPT: Self-employed 30+ hours/week" },
        { value: "EXEMPT: Attends drug or alcohol treatment", label: "EXEMPT: Attends drug or alcohol treatment" },
        { value: "EXEMPT: Homeless", label: "EXEMPT: Homeless" },
        { value: "EXEMPT: Age 55 or more with no skills", label: "EXEMPT: Age 55 or more with no skills" },
        { value: "EXEMPT: Temporary illness lasting > 90 days", label: "EXEMPT: Temporary illness lasting > 90 days" },
        { value: "EXEMPT: Child care problems", label: "EXEMPT: Child care problems" },
        { value: "EXEMPT: Migrant or seasonal worker", label: "EXEMPT: Migrant or seasonal worker" },
        { value: "EXEMPT: Temporarily laid off and will return", label: "EXEMPT: Temporarily laid off and will return" },
        { value: "EXEMPT: Domestic violence counseling", label: "EXEMPT: Domestic violence counseling" },
        { value: "EXEMPT:  Transitional housing", label: "EXEMPT:  Transitional housing" },
        { value: "EXEMPT: Convicted offender working for no pay", label: "EXEMPT: Convicted offender working for no pay" },
        { value: "EXEMPT: No aceess to transportation", label: "EXEMPT: No aceess to transportation" },
        { value: "EXEMPT: Attends drug or alcohol treatment", label: "EXEMPT: Attends drug or alcohol treatment" },
        { value: "ATTENDING: approved work activity 20+ hr/week", label: "ATTENDING: approved work activity 20+ hr/week" },
        { value: "ATTENDING: school at least part-time", label: "ATTENDING: school at least part-time" },
        { value: "EMPLOYED: 20+ hrs/wk OR 80+ hrs/mo", label: "EMPLOYED: 20+ hrs/wk OR 80+ hrs/mo" },
        { value: "SELF-EMPLOYED 30+ hrs/wk", label: "SELF-EMPLOYED 30+ hrs/wk" },
        { value: "COMBINATION: of work/activities 20+ hrs/wk OR 80+ hrs/mo", label: "COMBINATION: of work/activities 20+ hrs/wk OR 80+ hrs/mo" },
        { value: "GOOD CAUSE: Illness", label: "GOOD CAUSE: Illness" },
        { value: "GOOD CAUSE: Caring for ill hh member", label: "GOOD CAUSE: Caring for ill hh member" },
        { value: "GOOD CAUSE: Emergency", label: "GOOD CAUSE: Emergency" },
        { value: "GOOD CAUSE: No transportation", label: "GOOD CAUSE: No transportation" },
        { value: "GOOD CAUSE: Voluntary quit discrimination", label: "GOOD CAUSE: Voluntary quit discrimination" },
        { value: "GOOD CAUSE: Voluntary quit risk to health and safety", label: "GOOD CAUSE: Voluntary quit risk to health and safety" },
        { value: "GOOD CAUSE: Voluntary quit unfit to perform duties", label: "GOOD CAUSE: Voluntary quit unfit to perform duties" },
        { value: "GOOD CAUSE: Voluntary quit not in field of experience", label: "GOOD CAUSE: Voluntary quit not in field of experience" },
        { value: "GOOD CAUSE: Voluntary quit for religious reasons", label: "GOOD CAUSE: Voluntary quit for religious reasons" },
        { value: "GOOD CAUSE: Voluntary quit not paid timely", label: "GOOD CAUSE: Voluntary quit not paid timely" },
        { value: "GOOD CAUSE: Voluntary quit transition to new job or work activity", label: "GOOD CAUSE: Voluntary quit transition to new job or work activity" },
        { value: "GOOD CAUSE: Voluntary quit move required for job or other work activity", label: "GOOD CAUSE: Voluntary quit move required for job or other work activity" },
        { value: "APPLICATION APPROVED", label: "APPLICATION APPROVED" },
        { value: "APPLICATION DENIED: 3 months already received", label: "APPLICATION DENIED: 3 months already received" },
        { value: "APPLICATION DENIED: non-ABAWD reason", label: "APPLICATION DENIED: non-ABAWD reason" },
        { value: "1st month not complying: SENT WARNING", label: "1st month not complying: SENT WARNING" },
        { value: "2nd month not complying: SENT WARNING", label: "2nd month not complying: SENT WARNING" },
        { value: "3rd month not complying: SENT NOAA & Entered 526 Code", label: "3rd month not complying: SENT NOAA & Entered 526 Code" },
        { value: "CASE CLOSED 3rd Month", label: "CASE CLOSED 3rd Month" },
        { value: "CASE CLOSED: Voluntary Quit", label: "CASE CLOSED: Voluntary Quit" },
        { value: "CASE CLOSED: Other reason", label: "CASE CLOSED: Other reason" },
        { value: "REGAINED: 1st month: 30 Days of Compliance", label: "REGAINED: 1st month: 30 Days of Compliance" },
        { value: "REGAINED: 2nd month: SENT WARNING", label: "REGAINED: 2nd month: SENT WARNING" },
        { value: "REGAINED: 3rd month: SENT NOAA & Entered 526 Code", label: "REGAINED: 3rd month: SENT NOAA & Entered 526 Code" }
      ];


    // Modal dialog for Current Monthly Status
    var curStatusModalInstance = null;

    $scope.editStatus = function (result) {
        curStatusModalInstance = $modal.open({
          animation: ResultsController,
          templateUrl: 'editMonthlyStatus.html',
          controller: function($scope, $modalInstance, actions, result) {
            $scope.abawdActions = actions;

            $scope.ok = function () {
              result.abawdAction = $scope.actionTaken;
              $modalInstance.close(result);
            };

            $scope.cancel = function () {
              $modalInstance.dismiss('cancel');
            };
          },
          size: null,
          resolve: {
            actions: function () {
              return $scope.abawdActions;
            },
            result: function () {
              return result;
            }
          }
        });

        curStatusModalInstance.result.then(function (result) {
              //Save action as an annotation
              MLRest.extension('annotation', {
                method: 'POST',
                data: {
                  collections: ['ABAWDAction'],
                  user: "Unknown",
                  identifiers: [
                    { name: 'ClientID', value: result.personId }
                  ],
                  properties: [
                      { name: 'customerName', value: result.firstName + " " + result.lastName },
                      { name: 'customerDoB', value: result.dob },
                      //{ name: 'certificationPeriod', value: $scope.person.certPeriod },
                      { name: 'abawdAction', value: result.abawdAction},
                      { name: 'annotationType', value: 'ABAWDAction' }
                  ]
                }
                }).then(function(response) {
                    if(response.data.results.length == 0) {
                      $scope.error = true;
                      $scope.reason = 'Unknown Error';
                    } else if(response.data.results[0].error) {
                      $scope.error = true;
                      $scope.reason = response.data.results[0].reason;
                    } else { $scope.reason = 'ABAWD Determination Saved'; }
                });


              console.log("action taken: " + result.abawdAction);
            }, function () {
              console.log('Modal dismissed at: ' + new Date());
            });

    };

    // Modal dialog for Notification
    var notificationModalInstance = null;

    $scope.createNotification = function (result) {
        notificationModalInstance = $modal.open({
          animation: ResultsController,
          templateUrl: 'notification.html',
          controller: function($scope, $modalInstance, languagePrefs, notifications, result) {
            $scope.notificationTypes = notifications;
            $scope.languagePrefs = languagePrefs;
            $scope.result = result;
            $scope.result.notificationDate = new Date();

            $scope.ok = function () {
              result.notification = $scope.notification;
              result.languagePref = $scope.languagePref;
              $modalInstance.close(result);
            };

            $scope.cancel = function () {
              $modalInstance.dismiss('cancel');
            };
          },
          size: null,
          resolve: {
            languagePrefs: function () {
              return $scope.languagePrefs;
            },
            notifications: function () {
              return $scope.notificationTypes;
            },
            result: function () {
              return result;
            }
          }
        });

        notificationModalInstance.result.then(function (result) {
              console.log("notification type: " + result.notification);
              console.log("notification Date: " + result.notificationDate);
              console.log("ldssID: " + result.ldssID);
              console.log("ldssAddress: " + result.ldssAddress);
              console.log("client id: " + result.personId);
              console.log("languageCode: " + result.languagePref);
              console.log(" name: " + result.firstName + " " + result.lastName);
              console.log("mailing address: " + result.address);
              console.log("telephoneNum: " + result.telephoneNum);
              console.log("appointmentDatetime: " + result.appointmentDatetime);


              //Save notification as an annotation
              /*
              MLRest.extension('annotation', {
                method: 'POST',
                data: {
                  collections: ['ABAWDNotification'],
                  user: "Unknown",
                  identifiers: [
                    { name: 'ClientID', value: result.personId }
                  ],
                  properties: [
                      { name: 'customerName', value: result.firstName + " " + result.lastName },
                      { name: 'customerDoB', value: result.dob },
                      //{ name: 'certificationPeriod', value: $scope.person.certPeriod },
                      { name: 'notification', value: result.notification},
                      { name: 'annotationType', value: 'ABAWDNotification' }
                  ]
                }
                }).then(function(response) {
                    if(response.data.results.length == 0) {
                      $scope.error = true;
                      $scope.reason = 'Unknown Error';
                    } else if(response.data.results[0].error) {
                      $scope.error = true;
                      $scope.reason = response.data.results[0].reason;
                    } else { $scope.reason = 'ABAWD Determination Saved'; }
                });
                */

              var fileName = "test.pdf";
              var a = document.createElement("a");
              document.body.appendChild(a);
              //a.style = "display: none";

              MLRest.extension('notification', {
                method: 'POST',
                responseType: 'blob',
                params: {
                  'rs:LDSS': result.ldssID,
                  'rs:LDSS-Address': result.ldssAddress,
                  'rs:notice-date': result.notificationDate,
                  'rs:clientID': result.personId,
                  'rs:clientLanguagePreferenceCode': result.languagePref,
                  'rs:recipient-name': result.firstName + " " + result.lastName,
                  'rs:recipient-mailing-address1': result.address,
                  'rs:recipient-mailing-address2': 'temp2',
                  'rs:appointment-dateTime': result.appointmentDatetime,
                  'rs:telephone-contact-number': result.telephoneNum,
                  'rs:noticeType': 'AppointmentNotice'
                }
              }).then(function(response) {
                  var file = new Blob([response.data], {type: 'application/pdf'});
                  var fileURL = URL.createObjectURL(file);

                  a.href = fileURL;
                  a.download = fileName;
                  a.click();

                  //$scope.content = $sce.trustAsResourceUrl(fileURL);
              });

            }, function () {
              console.log('Modal dismissed at: ' + new Date());
            });
    };


    $scope.downloadNotification = function () {
      var fileName = "test.pdf";
      var a = document.createElement("a");
      document.body.appendChild(a);
      //a.style = "display: none";

      MLRest.extension('notification', {
        method: 'POST',
        responseType: 'blob',
        params: {
          'rs:LDSS': 'Ann',
          'rs:LDSS-Address': 'temp',
          'rs:notice-date': '08-11-2016',
          'rs:clientID': '12343',
          'rs:clientLanguagePreferenceCode': 'en',
          'rs:recipient-name': 'Jane',
          'rs:recipient-mailing-address1': 'temp2',
          'rs:recipient-mailing-address2': 'temp2',
          'rs:appointment-dateTime': '12:00',
          'rs:telephone-contact-number': '301-454-1234',
          'rs:noticeType': 'AppointmentNotice'
        }
      }).then(function(response) {
          var file = new Blob([response.data], {type: 'application/pdf'});
          var fileURL = URL.createObjectURL(file);

          a.href = fileURL;
          a.download = fileName;
          a.click();

          //$scope.content = $sce.trustAsResourceUrl(fileURL);
      });

    };

    //Sum Income Summary
    $scope.totalIncome = function (income) {
      var incomeTotal = 0;
      if(income != null) {
        income.map(function (item, index) {
          incomeTotal += item.IncomeAmount;
        });
      }
      return incomeTotal;
    };

    //Sum Work Hours
    $scope.totalWorkHours = function (income) {
      var wrkTotal = 0;
      if(income != null) {
        income.map(function (item, index) {
          wrkTotal += item.IncomeWorkHoursNumber
        });
      }
      return wrkTotal;
    };

    $scope.flagScreened = function (abawdStatus) {
      if(abawdStatus != null) {
        return "screened-cell";
      }
      return null;
    };

    $scope.flagPregDueDate = function (pregDate) {
      if(pregDate != null) {
        var startDateTime = Date.parse(pregDate);
        var lastYear = new Date();
        lastYear.setMonth(lastYear.getMonth() - 12);
        var lastYearTime = lastYear.getTime();
        if(startDateTime >= lastYearTime) {
          return "attention-cell";
        }
      }
      return null;
    };

    $scope.flagIncome = function (income) {
      if(income != null) {
        if($scope.totalIncome(income) <= 217.50) {
          return "attention-cell";
        }
      }
      return null;
    };

    $scope.flagWorkHours = function (income) {
      if(income != null) {
        if($scope.totalWorkHours(income) < 30) {
          return "attention-cell";
        }
      }
      return null;
    };


  }
}());
