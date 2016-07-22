(function () {
  'use strict';
  angular.module('app.detail')
    .directive('caseDetail', CaseDetail)
    .controller('CaseDetailCtrl', CaseDetailCtrl);

  function CaseDetail() {
    return {
      restrict: 'E',
      controller: 'CaseDetailCtrl',
      controllerAs: 'ctrl',
      templateUrl: 'app/detail/case/case-detail.html',
      scope: {
        case: '='
      }
    };
  }

  CaseDetailCtrl.$inject = ['$scope', '$location', 'MLSearchFactory', 'MLRest'];
  
  var superCtrl = MLSearchController.prototype;
  CaseDetailCtrl.prototype = Object.create(superCtrl);
  
  function CaseDetailCtrl($scope, $location, MLSearchFactory, MLRest) {
    var ctrl = this;
    
    var mlSearch = MLSearchFactory.newContext({ queryOptions: 'all' });
    
    superCtrl.constructor.call(ctrl, $scope, $location, mlSearch);
    
    ctrl.relationships = [];
    // Relationship Graph Configuration
    ctrl.graphOptions = {
        nodes : {
          shape: "dot",
          size: 5
        },
        physics: {
            barnesHut: {
              gravitationalConstant: -3500,
              centralGravity: 0.15,
              springLength: 225,
              springConstant: 0.01 /*,
              damping: 0.12,
              avoidOverlap: 0.25 */
            },
            maxVelocity: 22,
            minVelocity: 0.2,
            timestep: 0.44
          },
          edges: {
                arrows: {
                    to: {enabled: true, scaleFactor: 0.5}
                },
                width: 1,
                selfReferenceSize: 20,
                physics: true,
                dashes: true,
                smooth: {
                  enabled: true,
                  type: "dynamic",
                  roundness: 0.5
                }
        }
    };
    
    ctrl.init = function () {
    	
    	/* Call Relationship Endpoint for Relationship data
        MLRest.extension('relationships', {
          method: 'GET',
          params: {
          }
        }).then(function(response) {
          ctrl.relationships = response.data
        });       
        */
    	
      if($scope.case && $scope.case.headers.ParticipationIds[0].ServiceCaseId) {
        mlSearch.addAdditionalQuery(
          {
            'value-query': {
              'json-property': 'serviceCaseId',
              'type': 'number',
              'text': [$scope.case.headers.ParticipationIds[0].ServiceCaseId]
            }
          }
        );
      }
      superCtrl.init.apply(ctrl, arguments);
    };
    
    ctrl.updateSearchResults = function (data) {
	  superCtrl.updateSearchResults.apply(ctrl, arguments);
    };
    
    // Sort related options.  Edit as needed to identify sortable columns
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
      this._search();
    };
    
    $scope.sort = {
      field: 'sc',
      order: 'd'
    };
        
    // Page options
    ctrl.pageLength = 10;
   
    ctrl.selectPage = function() {
      this.mlSearch.setPage(this.page);
      this._search();
    };
      
    ctrl.init();
  }
}());
