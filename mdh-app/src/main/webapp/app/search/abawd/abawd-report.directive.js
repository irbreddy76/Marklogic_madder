(function () {
  'use strict';

  angular.module('app.search')
    .directive('abawdReport', AbawdReport)
    .controller('AbawdReportCtrl', AbawdReportCtrl);

  AbawdReportCtrl.$inject = ['$scope'];

  function AbawdReport() {
    return {
      restrict: 'E',
      scope: {
        person: '=',
        search: '&',
        suggest: '&',
        clearText: '&'
      },
      controller: 'AbawdReportCtrl',
      templateUrl: 'app/search/abawd/abawd-report.html'
    };
  }

  function AbawdReportCtrl($scope) {

// Start Angular Datepicker functions
// Following functions are used by angular datePicker 
// We may need to move this to a separate file - TBD	
  $scope.open = function($event) {
    $scope.status.openedDoB = true;
  };

  $scope.openDoBTo = function($event) {
    $scope.status.openedDoBTo = true;
  };
  
  $scope.openDoBFrom = function($event) {
    $scope.status.openedDoBFrom = true;
  };

  $scope.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate', 'MM/dd/yyyy'];
  $scope.format = $scope.formats[0];
  $scope.status = {
    openedDoB: false,
    openedDoBTo: false,
    openedDoBFrom: false,
    isNameOpen: true,
    isAddressOpen: false,
    isDetailOpen: false
  };

  var tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  var afterTomorrow = new Date();
  afterTomorrow.setDate(tomorrow.getDate() + 2);
  $scope.events =
    [
      {
        date: tomorrow,
        status: 'full'
      },
      {
        date: afterTomorrow,
        status: 'partially'
      }
    ];
// End Angular Datepicker functions	
  }
}());
