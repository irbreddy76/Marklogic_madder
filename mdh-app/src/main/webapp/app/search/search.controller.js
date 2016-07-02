/* global MLSearchController */
(function () {
  'use strict';

  angular.module('app.search')
    .controller('SearchCtrl', SearchCtrl);

  SearchCtrl.$inject = ['$scope', '$location', 'userService', 'MLSearchFactory', 'personHelper', 'MLRest'];

  // inherit from MLSearchController
  var superCtrl = MLSearchController.prototype;
  SearchCtrl.prototype = Object.create(superCtrl);

  function SearchCtrl($scope, $location, userService, searchFactory, personHelper, MLRest) {
    var ctrl = this;
    ctrl.runMapSearch = false;
	
    var mlSearch = searchFactory.newContext({ queryOptions: 'all' });

	ctrl.myFacets = {};

    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

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
      switch(mode) {
        case 'person':
          ctrl.mode = mode;
          ctrl.doSearch(ctrl.person);
          break;
        default:
          ctrl.mode = mode;
          ctrl.search(this.qtext);
          break;
      }
    };    
    
    ctrl.doSearch = function(person) {
      //console.log(ctrl.person.lastName);
      personHelper.updatePerson(person);
      var params = personHelper.getPersonQueryParams(person);
      console.log(params);
      MLRest.extension('person', {
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
          ctrl.doSearch(ctrl.person);
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
      ctrl.person = {};
      ctrl.clearFacets();
    };    
    
    ctrl.toggleSort = function(field) {
      if($scope.sort.field === field) {
        if($scope.sort.order === 'd') {
          $scope.sort.order = 'a';
        } else {
          $scope.sort.field = 'ws';
          $scope.sort.order = 'd';
        }
      } else {
        $scope.sort.field = field;
        $scope.sort.order = 'd';
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
      field: 'sc',
      order: 'd'
    };
    
  }
}());
