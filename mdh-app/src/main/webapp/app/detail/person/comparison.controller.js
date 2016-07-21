(function () {
  'use strict';
  angular.module('person.compare')
    .controller('ComparisonCtrl', ComparisonCtrl);

  ComparisonCtrl.$inject = ['originalDoc', 'candidateDoc', '$scope', '$location', '$state',
                            'MLRest'];
  function ComparisonCtrl(originalDoc, candidateDoc, $scope, $location, $state, mlRest) {
    var ctrl = this;
    
    ctrl.errMessage = null;
    ctrl.merging = false;
    
    ctrl.originalDoc = originalDoc.document;
    ctrl.candidateDoc = candidateDoc.document;
    
    ctrl.merge = function() {
      ctrl.merging = true;
      mlRest.extension('merge', {
        method: 'PUT',
        params: {
          'rs:primary': originalDoc.uri,
          'rs:secondary': candidateDoc.uri
        }
      }).then (function(response) {
        var results = response.data;
        ctrl.merging = false;
        if(response.data.error) {
          ctrl.errMessage = response.data.error;
        } else if(response.data.uri) {
          $state.go('root.view', {uri: response.data.uri});
        }
      });
    };
    
    ctrl.cancel = function() {
      $state.go('root.view', {uri: originalDoc.uri})
    };
  }
}());
