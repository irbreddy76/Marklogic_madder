(function () {
  'use strict';
  angular.module('person.compare')
    .directive('comparePerson', ComparePerson)
    .controller('ComparePersonCtrl', ComparePersonCtrl);

  function ComparePerson() {
    return {
      restrict: 'E',
      controller: 'ComparePersonCtrl',
      controllerAs: 'ctrl',
      templateUrl: 'app/detail/person/compare-person.html',
      scope: {
        person: '=',
        uri: '='
      }
    };
  }

  ComparePersonCtrl.$inject = ['$scope', '$filter'];
  function ComparePersonCtrl($scope, $filter) {
    var ctrl = this;
    
    ctrl.otherNames = {
      selected: null,
      index: null,
      list: []
    };
    
    ctrl.participations = {
      selected: null,
      index: null,
      list: []
    };

    ctrl.addresses = {
      selected: null,
      index: null,
      list: []
    };
    
    ctrl.persons = {
      selected: null,
      index: null,
      list: []
    };
    
    ctrl.images = [];
    
    $scope.status = {
      isPersonOpen: true,
      isPrimaryOpen: true,
      isAltNamesOpen: false,
      isDemographicsOpen: false,
      isAltDemoOpen: false,
      isAddressOpen: false,
      isParticipationOpen: false,
      isProgramOpen: false
    };
    
    ctrl.nextItem = function(cursor) {
      if(cursor.index === (cursor.list.length - 1)) {
    	cursor.index = 0;
      }	else {
    	cursor.index = cursor.index + 1;
      }
      cursor.selected = cursor.list[cursor.index];
    };
    
    ctrl.prevItem = function(cursor) {
      if(cursor.index === 0) {
      	cursor.index = cursor.list.length - 1;
      }	else {
      	cursor.index = cursor.index - 1;
      }
      cursor.selected = cursor.list[cursor.index];
    };
    
    ctrl.init = function() {      
      for(var i = 0; i < $scope.person.content.records.length; i++) {
    	var currentRecord = $scope.person.content.records[i];
    	if(i === 0) {
          ctrl.otherNames.list = ctrl.otherNames.list.concat($filter('filter')(currentRecord.Person.PersonName, {PersonNameType: '!Primary'}, true));    		
    	} else {
          ctrl.otherNames.list = ctrl.otherNames.list.concat(currentRecord.Person.PersonName);
          ctrl.persons.list = ctrl.persons.list.push(currentRecord.Person);
    	}
    	ctrl.images = ctrl.images.concat(currentRecord.Person.PersonDigitalImage);
    	ctrl.participations.list = ctrl.participations.list.concat(currentRecord.ProgramParticipations);
      }
      
      ctrl.addresses.list = $scope.person.headers.Addresses;
      
      if(ctrl.addresses.list.length > 0) {
    	ctrl.addresses.selected = ctrl.addresses.list[0];
    	ctrl.addresses.index = 0;
      }
      
      if(ctrl.otherNames.list.length > 0) { 
        ctrl.otherNames.selected = ctrl.otherNames.list[0];
        ctrl.otherNames.index = 0;
      }
      
      if(ctrl.persons.list.length > 0) { 
        ctrl.persons.selected = ctrl.persons.list[0];
        ctrl.persons.index = 0;
      }
      
      if(ctrl.participations.list.length > 0) { 
        ctrl.participations.selected = ctrl.participations.list[0];
        ctrl.participations.index = 0;
      }
    };
    
    ctrl.init();
  }
}());
