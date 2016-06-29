(function () {
  'use strict';

  angular.module('search.personhelper', ['ml.common'])
    .service('personHelper', PersonHelper);
    
  PersonHelper.$inject = ['$rootScope', '$filter'];
  
  function PersonHelper($rootScope, $filter) {
    var personQueryPending;
    var personObject;
    
    function getPerson() {
      return personObject;
    }
    
    function updatePerson(person) {
      personObject = person;
    }
    
    function clearPerson() {
      personObject = {};
    }
    
    function checkStatus() {
      return personQueryPending;
    }
     
    function getPersonQueryParams(person) {
      var params = {
        'rs:target': 'query',
      };
      
      if(person.firstName) {
        params['rs:first'] = person.firstName;
      }
      
      if(person.middleName) {
        params['rs:middle'] = person.middleName;
      }
      
      if(person.lastName) {
        params['rs:last'] = person.lastName;
      }
      
      if(person.address) {
        if(person.address.street) {
          params['rs:street'] = person.address.street;
        }
        
        if(person.address.state) {
          params['rs:state'] = person.address.state;
        }
        
        if(person.address.city) {
          params['rs:city'] = person.address.city;
        }
        
        if(person.address.zip) {
          params['rs:zip'] = person.address.zip;
        }
      }
      
      if(person.dob){
        params['rs:dob'] = $filter('date')(person.dob, 'yyyy-MM-dd');
      }
      
      if(person.ssn) {
        params['rs:id'] = person.ssn;
      }
      return params;      
    }            
     
    return {
      getPerson: getPerson,
      updatePerson: updatePerson,
      clearPerson: clearPerson,
      checkStatus: checkStatus,
      getPersonQueryParams: getPersonQueryParams
    };
  }
}());