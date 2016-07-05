(function () {
  'use strict';

  angular.module('app.search')
    .directive('caseSearch', CaseSearch)
    .controller('CaseSearchCtrl', CaseSearchCtrl);

  CaseSearchCtrl.$inject = ['$scope'];

  function CaseSearch() {
    return {
      restrict: 'E',
      scope: {
        case: '=',
        search: '&',
        suggest: '&',
        clearText: '&'
      },
      controller: 'CaseSearchCtrl',
      templateUrl: 'app/search/case/case-search.html'
    };
  }

  function CaseSearchCtrl($scope) {

// Start Angular Datepicker functions
// Following functions are used by angular datePicker 
// We may need to move this to a separate file - TBD	
  $scope.openDateClicked = function($event) {
    $scope.status.openDate.opened = true;
  };
  
  $scope.closeDateClicked = function($event) {
    $scope.status.closeDate.opened = true;
  };

  $scope.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
  $scope.format = $scope.formats[0];
  $scope.status = {
    openDate: { opened: false },
    closeDate: { opened: false }
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
