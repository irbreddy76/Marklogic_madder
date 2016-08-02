(function () {

  'use strict';

  angular.module('annotation.view')
    .directive('viewAnnotation', ViewAnnotation)
    .controller('AnnotateViewCtrl', AnnotateViewCtrl)
    .controller('ViewAnnInstanceCtrl', ViewAnnInstanceCtrl);

  function ViewAnnotation() {
	    return {
	      restrict: 'E',
	      controller: 'AnnotateViewCtrl',
	      controllerAs: 'ctrl',
	      templateUrl: 'app/annotation/view-annotation-directive.html',
	      scope: {
	        params: '='
	      },
	    };
  }
  
  AnnotateViewCtrl.$inject = ['$scope', '$modal', 'MLRest', '$state', 'userService'];

  function AnnotateViewCtrl($scope, $modal, MLRest, $state, userService) {
    $scope.animationsEnabled = true;

    $scope.open = function (size) {
      var modalInstance = $modal.open({
        animation: $scope.animationsEnabled,
        templateUrl: 'app/annotation/view-annotation-content.html',
        controller: 'ViewAnnInstanceCtrl',
        size: size,
        resolve: {
          annotations: function () {
            return MLRest.extension('annotation', {
              method: 'GET',
              params: $scope.params
            }).then(function(response) {
              return response.annotations;  // Need to see what response looks like and convert to JSON if necessary            
            });
          }
        }
      });

      modalInstance.result.then(function () {
         // Do nothing when we click ok
      }, function () {
         // Do nothing when we click cancel
      });
    };

    $scope.toggleAnimation = function () {
      $scope.animationsEnabled = !$scope.animationsEnabled;
    };  
  }

  ViewAnnInstanceCtrl.$inject = ['$scope', '$modalInstance',  'annotations' ];
    
  function ViewAnnInstanceCtrl($scope, $modalInstance, annotations) {

    $scope.annotations = annotations;
    
    $scope.isAnnotationsEmpty = function() {
      if($scope.annotations.length > 0) { return false; }
      else { return true; }
    };
    
    $scope.ok = function () {
      $modalInstance.dismiss('cancel');
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };    
  }
}());