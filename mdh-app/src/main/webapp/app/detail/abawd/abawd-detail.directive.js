(function () {
  'use strict';
  angular.module('app.detail')
    .directive('abawdDetail', AbawdDetail)
    .controller('AbawdDetailCtrl', AbawdDetailCtrl);

  function AbawdDetail() {
    return {
      restrict: 'E',
      controller: 'AbawdDetailCtrl',
      controllerAs: 'ctrl',
      templateUrl: 'app/detail/abawd/abawd-detail.html',
      scope: {
        person: '=',
        uri: '='
      }
    };
  }

  AbawdDetailCtrl.$inject = ['$scope', '$location', '$filter', 'MLRest'];
  function AbawdDetailCtrl($scope, $location, $filter, mlRest) {
    var ctrl = this;
    
    ctrl.determinations = [];
    ctrl.isLoading = false;
   
    ctrl.params = [
      { label: 'Screening Question 1', name:'questionOne', value: ''},
      { label: 'Screening Question 2', name:'questionTwo', value: ''},
      { label: 'ABAWD Status', name: 'abawdStatus', value: '' }
    ];
 
    $scope.status = {
      isPersonOpen: true,
      isAddressOpen: false,
      isDisabilityOpen: false,
      isIncomeOpen: false,
      isUnearnedOpen: false,
      isDeterminationOpen: false
    };
    
    ctrl.init = function () {
      ctrl.isLoading = true;
      mlRest.extension('annotation', {
        method: 'GET',
          params: {
            identifiers: $scope.person.headers.SystemIdentifiers
          }
        }).then(function(response) {
          ctrl.isLoading = false;
          ctrl.determinations = response.data.annotations
        });       
    };
    
    ctrl.init();
       
  }
}());
