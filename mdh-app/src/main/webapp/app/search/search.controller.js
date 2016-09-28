/* global MLSearchController */
(function () {
  'use strict';

  angular.module('app.search')
    .controller('SearchCtrl', SearchCtrl);

  SearchCtrl.$inject = ['$scope', '$location', 'userService', 'MLSearchFactory',
                        'personHelper', 'caseHelper', 'abawdHelper', 'MLRest', 'searchHelper', 'user'];

  // inherit from MLSearchController
  var superCtrl = MLSearchController.prototype;
  SearchCtrl.prototype = Object.create(superCtrl);

  function SearchCtrl($scope, $location, userService, searchFactory,
		  personHelper, caseHelper, abawdHelper, MLRest, searchHelper, user) {
    var ctrl = this;
    ctrl.runMapSearch = false;
    ctrl.abawdOnly = user.abawdOnly;

    var mlSearch = searchFactory.newContext({ queryOptions: 'all' });

	ctrl.myFacets = {};

    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);

    ctrl.report = abawdHelper.getReport(); //Object used to persist any user provided search params
    ctrl.case = caseHelper.getCase();
    ctrl.person = personHelper.getPerson();
    ctrl.searchParams = searchHelper.getParams();

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
      if(ctrl.searchParams.searchMode != mode) {
    	  ctrl.searchParams.page = 1;
    	  this.mlSearch.activeFacets = [];
      }
      ctrl.searchParams.searchMode = mode;
      switch(mode) {
        case 'case':
          ctrl.searchParams.abawdFacets = [];
          this.mlSearch.options.queryOptions = 'case';
          ctrl.searchParams.tabStatus.isCaseActive = true;
          ctrl.searchParams.tabStatus.isPersonActive = false;
          ctrl.searchParams.tabStatus.isBasicActive = false;
          ctrl.searchParams.tabStatus.isAbawdActive = false;
          break;
        case 'abawd':
          this.mlSearch.activeFacets = ctrl.searchParams.abawdFacets;
          this.mlSearch.options.queryOptions = 'abawd';
          ctrl.searchParams.tabStatus.isCaseActive = false;
          ctrl.searchParams.tabStatus.isPersonActive = false;
          ctrl.searchParams.tabStatus.isBasicActive = false;
          ctrl.searchParams.tabStatus.isAbawdActive = true;
          break;
        case 'person':
          ctrl.searchParams.abawdFacets = [];
          this.mlSearch.options.queryOptions = 'all';
          ctrl.searchParams.tabStatus.isCaseActive = false;
          ctrl.searchParams.tabStatus.isPersonActive = true;
          ctrl.searchParams.tabStatus.isBasicActive = false;
          ctrl.searchParams.tabStatus.isAbawdActive = false;
          break;
        default:
          ctrl.searchParams.abawdFacets = [];
          this.mlSearch.options.queryOptions = 'all';
          ctrl.searchParams.tabStatus.isCaseActive = false;
          ctrl.searchParams.tabStatus.isPersonActive = false;
          ctrl.searchParams.tabStatus.isBasicActive = true;
          ctrl.searchParams.tabStatus.isAbawdActive = false;
          break;
      }

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

    ctrl.doABAWDSearch = function(report) {
      this.mlSearch.options.queryOptions = 'abawd';
      ctrl.searchParams.abawdFacets = this.mlSearch.activeFacets;
      abawdHelper.updateReport(report);
      var params = abawdHelper.getReportQueryParams(report);
      console.log(params);
      MLRest.extension('abawd', {
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
    	 mlSearch.setPageLength(ctrl.searchParams.pageLength).setPage(this.page);
         mlSearch.additionalQueries = [];
         mlSearch.additionalQueries.push(response.data);
         return this._search();
       }
    };

    ctrl.newSearch = function(qtext) {
      ctrl.searchParams.page = 1;
      ctrl.search(qtext);
    }

    ctrl.search = function(qtext) {
      searchHelper.updateParams(ctrl.searchParams);
      this.page = ctrl.searchParams.page;
      switch(ctrl.searchParams.searchMode) {
        case 'person':
          ctrl.doPersonSearch(ctrl.person);
          break;
        case 'case':
          ctrl.doCaseSearch(ctrl.case);
          break;
          case 'abawd':
            ctrl.doABAWDSearch(ctrl.abawd);
            break;
        default:
          if ( arguments.length ) {
				this.qtext = qtext;
			}
			this.mlSearch.setText( this.qtext ).setPageLength(ctrl.searchParams.pageLength).setPage(this.page);
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
      switch(ctrl.searchParams.searchMode) {
        case 'person':
          ctrl.person = {};
          personHelper.clearPerson();
          break;
        case 'case':
          ctrl.case = {};
          caseHelper.clearCase();
          break;
        case 'abawd':
          ctrl.abawd = {};
          abawdHelper.clearReport();
          break;
        default:
          this.qtext = {};
          break;
      }
      searchHelper.resetParams();
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

    ctrl.selectPage = function() {
      //this.mlSearch.setPage(this.page);
      ctrl.search(this.qtext);
    };

    $scope.sort = {
      field: 'ws',
      order: 'd'
    };

    /*
    this.parseExtraURLParams = function() {
        var params = this.$location.search();
        var queryParamsChanged = false;

        if(params.mode != ctrl.mode) {
          ctrl.mode = params.mode;
          queryParamsChanged = true;
        }

        if(params.pageLength && params.pageLength != ctrl.pageLength) {
          ctrl.pageLength = params.pageLength
          queryParamsChanged = true;
        } else if(params.pageLength) {
          // Do nothing if page length hasn't changed
        } else if(ctrl.pageLength != 10) {
        	ctrl.pageLength = 10;
        	queryParamsChanged = true;
        }
        return queryParamsChanged;
    };

    this.updateExtraURLParams = function() {
      var paramsToPost = {};

      if(ctrl.pageLength != 10) { paramsToPost.pageLength = ctrl.pageLength; }
      if(ctrl.mode != 'basic') { paramsToPost.mode = ctrl.mode; }

      var params = _.chain( this.$location.search() )
        .omit( ['pageLength', 'mode'] )
        .merge( paramsToPost )
        .value();

      this.$location.search( params );

      return this;
    };
    */
  }
}());
