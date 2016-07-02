(function () {
  'use strict';

  angular.module('app.search')
    .directive('personSearch', PersonSearch)
    .controller('PersonSearchCtrl', PersonSearchCtrl);

  PersonSearchCtrl.$inject = ['$scope'];

  function PersonSearch() {
    return {
      restrict: 'E',
      scope: {
        person: '=',
        search: '&',
        suggest: '&',
        clearText: '&'
      },
      controller: 'PersonSearchCtrl',
      templateUrl: 'app/search/person-search.html'
    };
  }

  function PersonSearchCtrl($scope) {

// Start Angular Datepicker functions
// Following functions are used by angular datePicker 
// We may need to move this to a separate file - TBD	
  $scope.open = function($event) {
    $scope.status.opened = true;
  };

  $scope.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
  $scope.format = $scope.formats[0];
  $scope.status = {
    opened: false,
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
