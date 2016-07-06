/* global MLSearchController */
(function () {
  'use strict';

  angular.module('app.search')
    .controller('SearchCtrl', SearchCtrl);

  SearchCtrl.$inject = ['$scope', '$location', 'userService', 'MLSearchFactory', 'personHelper', 'caseHelper', 'MLRest'];

  // inherit from MLSearchController
  var superCtrl = MLSearchController.prototype;
  SearchCtrl.prototype = Object.create(superCtrl);

  function SearchCtrl($scope, $location, userService, searchFactory, personHelper, caseHelper, MLRest) {
    var ctrl = this;
    ctrl.runMapSearch = false;
	
    var mlSearch = searchFactory.newContext({ queryOptions: 'all' });

	ctrl.myFacets = {};

    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

    ctrl.case = caseHelper.getCase();
    ctrl.person = personHelper.getPerson();
    ctrl.mode = 'basic';
    
    ctrl.init();

    ctrl.updateSearchResults = function (data) {
			superCtrl.updateSearchResults.apply(ctrl, arguments);
			ctrl.myFacets.facets = data.facets;
		};

    ctrl.setSnippet = function(type) {
      mlSearch.setSnippet(type);
      ctrl.search();
    };

    // Re-run search based off current mode
    ctrl.setMode = function(mode) {
      ctrl.mode = mode;
      $scope.sort = {
        field: 'ws',
        order: 'd'
      };
      this.mlSearch.setSort($scope.sort.field + $scope.sort.order);
      ctrl.search(this.qtext);
    };    
    
    ctrl.doPersonSearch = function(person) {
      this.mlSearch.options.queryOptions = 'all';
      personHelper.updatePerson(person);
      var params = personHelper.getPersonQueryParams(person);
      console.log(params);
      MLRest.extension('person', {
        method: 'GET',
        params: params
      }).then(this.submitSearch.bind(this));      
    };
    
    ctrl.doCaseSearch = function(caseParams) {
      this.mlSearch.options.queryOptions = 'case';
      caseHelper.updateCase(caseParams);
      var params = caseHelper.getCaseQueryParams(caseParams);
      console.log(params);
      MLRest.extension('case', {
        method: 'GET',
        params: params
      }).then(this.submitSearch.bind(this));      
    };   
    
    ctrl.submitSearch = function(response) {
       if(response.data) {
         this.mlSearch.setPageLength(ctrl.pageLength);
         mlSearch.additionalQueries = [];
         mlSearch.additionalQueries.push(response.data);
         return this._search();
       }
    };     

    ctrl.newSearch = function(qtext) {
      this.page = 1;
      ctrl.search(qtext);
    }
    
    ctrl.search = function(qtext) {      
      switch(ctrl.mode) {
        case 'person':
          ctrl.doPersonSearch(ctrl.person);
          break;
        case 'case':
          ctrl.doCaseSearch(ctrl.case);
          break;
        default:
          if ( arguments.length ) {
				this.qtext = qtext;
			}
			this.mlSearch.setText( this.qtext ).setPageLength(ctrl.pageLength);
			if (ctrl.runMapSearch) {
				mlSearch.additionalQueries = [];
				mlSearch.additionalQueries.push(ctrl.getGeoConstraint());
			}
			return this._search();
          break;
      }	
    };

		ctrl.mapBoundsChanged = function(bounds) {
			ctrl.bounds = bounds;
			ctrl.search();
		};

		ctrl.mapOptions = {
			center: [-97.846, 38.591],
			zoom: 4,
			baseMap: 'national-geographic'
		};

		ctrl.bounds = {
			'south': 30.0,
			'west': -100.0,
			'north': 45.0,
			'east': -50.0
		};

		ctrl.getGeoConstraint = function() {
			return {
				'custom-constraint-query': {
					'constraint-name': 'geo-point',
					'box': [ ctrl.bounds ]
				}
			};
		};
 	  
		ctrl.toggleMapSearch = function (){
			if(ctrl.runMapSearch) {
				mlSearch.additionalQueries.push(ctrl.getGeoConstraint());
			}
			else {
				mlSearch.additionalQueries.pop(ctrl.getGeoConstraint());
			}
			this._search();
		};

    $scope.$watch(userService.currentUser, function(newValue) {
      ctrl.currentUser = newValue;
    });

    ctrl.clearText = function() {
      switch(ctrl.mode) {
        case 'person':
          ctrl.person = {};
          personHelper.clearPerson();
          break;
        case 'case':
          ctrl.case = {};
          caseHelper.clearCase();
          break;
        default:
          this.qtext = {};
          break;
      }
      this.mlSearch.clearAllFacets();
      ctrl.search(this.qtext);
    };    
    
    ctrl.toggleSort = function(field) {
      if($scope.sort.field === field && $scope.sort.order === 'a') {
        $scope.sort.field = 'ws';
        $scope.sort.order = 'd';
      } else if($scope.sort.field != field) {
        $scope.sort.field = field;
        $scope.sort.order  = 'd';
      } else {
        $scope.sort.order = 'a';
      }
      
      this.mlSearch.setSort($scope.sort.field + $scope.sort.order);
      ctrl.search(this.qtext);
    };
        
    ctrl.pageLength = 10;
   
    ctrl.selectPage = function() {
      this.mlSearch.setPage(this.page);
      ctrl.search(this.qtext);
    };
 
    $scope.sort = {
      field: 'ws',
      order: 'd'
    };
    
  }
}());
