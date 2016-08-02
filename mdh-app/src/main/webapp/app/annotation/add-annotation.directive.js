(function () {

  'use strict';

  angular.module('annotation.add')
    .directive('addAnnotation', AddAnnotation)
    .controller('AddAnnotationCtrl', AddAnnotationCtrl)
    .controller('AddAnnInstanceCtrl', AddAnnInstanceCtrl);

  function AddAnnotation() {
    return {
      restrict: 'E',
      controller: 'AddAnnotationCtrl',
      controllerAs: 'ctrl',
      templateUrl: template,
      scope: {
        sourceUrl: '=',
        title: '=',
        params: '='      
      }
    };
  }
  
  function template(element, attrs) {
	var url;

	if (attrs.template) {
	  url = attrs.template;
	} else {
	  url = 'app/annotation/add-annotation-directive.html';
	}
	
	return url;
  }
  
  AddAnnotationCtrl.$inject = ['$scope', '$modal', 'MLRest', '$state', 'userService'];

  function AddAnnotationCtrl($scope, $modal, MLRest, $state, userService) {
    $scope.animationsEnabled = true;

    $scope.open = function (size) {
      var modalInstance = $modal.open({
        animation: $scope.animationsEnabled,
        templateUrl: 'app/annotation/add-annotation-content.html',
        controller: 'AddAnnInstanceCtrl',
        size: size,
        resolve: {
          params: function () {
            return {
              title: $scope.title,
              sourceUrl: $scope.sourceUrl,
              properties: $scope.params,
              comments: '',
              user: userService.currentUser().name
            };
          }
        }
      });

      modalInstance.result.then(function (params) {
        //call ML Rest here!
        
          MLRest.extension('annotation', {
            method: 'POST',
            data: {
              uri: params.sourceUrl,
              properties: params.properties,
              comments: params.comments,
              user: params.user
            }
          }).then(function(response) {
            $state.go('root.view', { uri: params.uri[1] }, { reload: true });
          });
        
      }, function () {
        
      });
    };

    $scope.toggleAnimation = function () {
      $scope.animationsEnabled = !$scope.animationsEnabled;
    };  
  }

  AddAnnInstanceCtrl.$inject = ['$scope', '$modalInstance', 'params' ];
    
  function AddAnnInstanceCtrl($scope, $modalInstance, params) {
    $scope.params = params;
    
    $scope.ok = function () {
      $modalInstance.close($scope.params);
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };    
  }

}());
