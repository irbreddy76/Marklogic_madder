(function () {
  'use strict';
  angular.module('app.detail')
    .directive('personDetail', PersonDetail)
    .controller('PersonDetailCtrl', PersonDetailCtrl);

  function PersonDetail() {
    return {
      restrict: 'E',
      controller: 'PersonDetailCtrl',
      controllerAs: 'ctrl',
      templateUrl: 'app/detail/person/person-detail.html',
      scope: {
        person: '='
      }
    };
  }

  PersonDetailCtrl.$inject = ['$scope'];
  function PersonDetailCtrl($scope) {
    var ctrl = this;
    
    $scope.status = {
      isPersonOpen: true,
      isAddressOpen: false,
      isParticipationOpen: false,
      isProgramOpen: false
    };
  }
}());
