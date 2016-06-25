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

    ctrl.selectPage = function() {
      switch(ctrl.mode) {
        case 'person':
          ctrl.doSearch(ctrl.person);
          break;
        default:
          ctrl.search();
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
         mlSearch.setPage( this.page );
         mlSearch.additionalQueries = [];
         mlSearch.additionalQueries.push(response.data);
         return this._search();
       }
    };     

    ctrl.search = function(qtext) {
			if ( arguments.length ) {
				this.qtext = qtext;
			}
			this.mlSearch.setText( this.qtext ).setPage( this.page );
			if (ctrl.runMapSearch) {
				mlSearch.additionalQueries = [];
				mlSearch.additionalQueries.push(ctrl.getGeoConstraint());
			}
			return this._search();
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
    };    
    
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
