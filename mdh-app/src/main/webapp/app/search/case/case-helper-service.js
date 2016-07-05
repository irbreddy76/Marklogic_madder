(function () {
  'use strict';

  angular.module('search.casehelper', ['ml.common'])
    .service('caseHelper', CaseHelper);
    
  CaseHelper.$inject = ['$rootScope', '$filter'];
  
  function CaseHelper($rootScope, $filter) {
    var caseObject = {};
    
    function getCase() {
      return caseObject;
    }
    
    function updateCase(caseParams) {
      caseObject = caseParams;
    }
    
    function clearCase() {
      caseObject = {};
    }
    
    function getCaseQueryParams(caseParams) {
      var params = {
        'rs:target': 'query',
      };

      if(caseParams.status) {
        params['rs:status'] = caseParams.status;
      }
      
      if(caseParams.closeDate) {
        params['rs:cd'] = $filter('date')(caseParams.closeDate, 'yyyy-MM-dd');
      }
      
      if(caseParams.closeCode) {
        params['rs:cc'] = caseParams.closeCode;
      }
      
      if(caseParams.caseType) {
        params['rs:ctype'] = caseParams.caseType;
      }
        
      if(caseParams.program) {
        params['rs:ppn'] = caseParams.program;
      }
        
      if(caseParams.caseId) {
        params['rs:caseId'] = caseParams.caseId;
      }
              
      return params;      
    }            
     
    return {
      getCase: getCase,
      updateCase: updateCase,
      clearCase: clearCase,
      getCaseQueryParams: getCaseQueryParams
    };
  }
}());
