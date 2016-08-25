(function () {
  'use strict';

  angular.module('search.params', [])
    .service('searchHelper', SearchHelper);

  SearchHelper.$inject = ['$rootScope', '$filter'];

  function SearchHelper($rootScope, $filter) {
    var searchParams = {
      searchMode: 'basic',
      pageLength: 10,
      page: 1,
      tabStatus: {
    	isBasicActive: true,
        isPersonActive: false,
        isCaseActive: false,
        isAbawdActive: false
      },
      abawdFacets: []
    };

    function getParams() {
      return searchParams;
    }

    function updateParams(params) {
      searchParams = params;
    }

    function resetParams() {
      //searchParams.searchMode = 'basic';
      searchParams.pageLength = 10;
      searchParams.page = 1;
      searchParams.abawdFacets = [];
    }
    
    return {
      getParams: getParams,
      updateParams: updateParams,
      resetParams: resetParams
    };
  }
}());
