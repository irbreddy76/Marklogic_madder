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
      isDeterminationOpen: false,
      isStatusOpen: false,
      isNotificationOpen: false
    };

    ctrl.clientID = null;
    ctrl.auNum = null;
    ctrl.doNum = null;

    ctrl.init = function () {
      ctrl.isLoading = true;
      var identifiers = [];
      for(var i = 0; i < $scope.person.headers.SystemIdentifiers.length; i++) {
    	  var currentIdentifier = $scope.person.headers.SystemIdentifiers[i];
    	  if(currentIdentifier.ClientID) {
    		  ctrl.clientID = currentIdentifier.ClientID;
    		  identifiers.push({ name: 'ClientID', value: currentIdentifier.ClientID });
    	  }

        //These Identifiers should not be included in the annotation identifiers
        if(currentIdentifier.AUNum) {
          ctrl.auNum = currentIdentifier.AUNum;
        }
        if(currentIdentifier.DONum) {
          ctrl.doNum = currentIdentifier.DONum;
        }
      }

      if(identifiers.length > 0) {
        mlRest.extension('annotation', {
          method: 'GET',
            params: {
              'rs:identifiers': identifiers,
              'rs:annotationType': 'all'
            }
          }).then(function(response) {
            ctrl.isLoading = false;
            ctrl.determinations = response.data.annotations
          });
      } else { ctrl.isLoading = false; }
    };

    ctrl.init();

  }
}());
