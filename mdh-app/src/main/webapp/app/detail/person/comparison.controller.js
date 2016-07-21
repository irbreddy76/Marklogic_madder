(function () {
  'use strict';
  angular.module('person.compare')
    .controller('ComparisonCtrl', ComparisonCtrl);

  ComparisonCtrl.$inject = ['originalDoc', 'candidateDoc', '$scope', '$location', 'MLRest'];
  function ComparisonCtrl(originalDoc, candidateDoc, $scope, $location, mlRest) {
    var ctrl = this;
    
    ctrl.originalDoc = originalDoc;
    ctrl.candidateDoc = candidateDoc;
    
    ctrl.merge = function() {
      mlRest.extension('merge', {
        method: 'PUT',
        params: {
          'rs:master': ctrl.master,
          'rs:uri': ctrl.candidate
        }
      })
    };
  }
}());
