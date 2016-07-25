(function () {
  'use strict';
  angular.module('app.detail')
    .directive('personDetail', PersonDetail)
    .controller('PersonDetailCtrl', PersonDetailCtrl);

  function PersonDetail() {
    return {
      restrict: 'E',
      controller: 'PersonDetailCtrl',
      controllerAs: 'ctrl',
      templateUrl: 'app/detail/person/person-detail.html',
      scope: {
        person: '=',
        uri: '='
      }
    };
  }

  PersonDetailCtrl.$inject = ['$scope', '$location', '$filter', 'MLRest'];
  function PersonDetailCtrl($scope, $location, $filter, mlRest) {
    var ctrl = this;
    
    ctrl.relationships = null;
    ctrl.suggestions = [];
    ctrl.persons = [];
    ctrl.participations = [];
    ctrl.otherNames = [];
    ctrl.images = [];
    ctrl.isLoading = false;
    
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
              springConstant: 0.01, 
              damping: 0.12/*,
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
    
    $scope.status = {
      isPersonOpen: true,
      isPrimaryOpen: true,
      isAltNamesOpen: false,
      isDemographicsOpen: false,
      isAltDemoOpen: false,
      isAddressOpen: false,
      isParticipationOpen: false,
      isProgramOpen: false,
      isSimilarOpen: false,
      isRelationsOpen: false
    };
    
    ctrl.processCandidates = function(response) {
      ctrl.suggestions = response.data.results;
      ctrl.isLoading = false;
    };
   
    ctrl.init = function() {
      ctrl.isLoading = true;
      mlRest.extension('similar', {
    	method: 'GET',
    	params: {
    	  'rs:uri': $scope.uri,
    	  'rs:limit': 10
    	}
      }).then(ctrl.processCandidates.bind(this));
      
      /* Call Relationship Endpoint for Relationship data */
      /*
      var chessieId;
      for(var i = 0; i < $scope.person.headers.SystemIdentifiers.length; i++) {
          var currentIdentifier = $scope.person.headers.SystemIdentifiers[i];
          if(currentIdentifier.chessieId) {
                // chessieId.push(currentIdentifier.chessieId)
          }
      }
      */
       mlRest.extension('relationship', {
         method: 'GET',
         params: {
          'rs:uri': $scope.uri,
          'rs:target' : 'person',
          'rs:format' : 'json-viz',
          /* 'rs:id' : 1006187 */
          'rs:id' : $scope.person.headers.SystemIdentifiers[0].chessieId
          //'rs:id' : 'chessieId'
         }
       }).then(function(response) {
         ctrl.relationships = response.data;
       }); 
      
      for(var i = 0; i < $scope.person.content.records.length; i++) {
    	var currentRecord = $scope.person.content.records[i];
    	if(i === 0) {
          ctrl.otherNames = ctrl.otherNames.concat($filter('filter')(currentRecord.Person.PersonName, {PersonNameType: '!Primary'}, true));    		
    	} else {
          ctrl.otherNames = ctrl.otherNames.concat(currentRecord.Person.PersonName);
          ctrl.persons.push(currentRecord.Person);
    	}
    	ctrl.images = ctrl.images.concat(currentRecord.Person.images);
    	ctrl.participations = ctrl.participations.concat(currentRecord.Participations);
      }
    };
    
    ctrl.init();
  }
}());
