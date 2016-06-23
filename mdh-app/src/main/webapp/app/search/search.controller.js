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
	ctrl.master = {};
	ctrl.user = {};

    var mlSearch = searchFactory.newContext({ queryOptions: 'all' });

	ctrl.myFacets = {};

    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

    ctrl.person = {};

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
        case 'detailed':
          ctrl.doSearch(ctrl.person);
          break;
        default:
          ctrl.search(this.qtext);
          break;
      }
    };    

    ctrl.doSearch = function(person) {
      //console.log(ctrl.person.lastName);
      var params = personHelper.getPersonQueryParams(person);
      console.log(params);
      MLRest.extension('person', {
        method: 'GET',
        params: params
      }).then(this.submitSearch.bind(this));
   
    };   
    
    ctrl.submitSearch = function(response) {
       if(response.data) {
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

		  ctrl.reset = function() {
			console.log("calling reset");
			//ctrl.user = angular.extend({}, ctrl.master);
			ctrl.user = angular.copy({});
			console.log(ctrl.user);
		  };
		  
		  ctrl.update = function(user) {
			console.log("calling update");
			ctrl.master = angular.copy(ctrl.user);
			console.log(ctrl.user);
			ctrl.search(ctrl.user.lastName);
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

    ctrl.clearText = function(field) {
    	console.log(field);
      switch(field) {
        case 'firstname':
          ctrl.person.firstName = null;
          break;
        case 'middlename':
          ctrl.person.middleName = null;
          break;
        case 'lastname':
          ctrl.person.lastname = null;
          break;
        case 'dob':
          ctrl.person.dob = null;
          break;
        case 'street':
          ctrl.person.address.street = null;
          break;
        case 'street':
          ctrl.person.address.city = null;
          break;
        case 'street':
          ctrl.person.address.state = null;
          break;
        case 'street':
          ctrl.person.address.zip = null;
          break;	
        default:
          ctrl.person = {};
          break;
      }
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
    opened: false
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
