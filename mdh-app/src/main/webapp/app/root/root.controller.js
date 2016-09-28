(function () {
  'use strict';

  angular.module('app.root')
    .controller('RootCtrl', RootCtrl);

  RootCtrl.$inject = ['messageBoardService', 'user'];

  function RootCtrl(messageBoardService, user) {
    var ctrl = this;
    ctrl.abawdOnly = user.abawdOnly;
    angular.extend(ctrl, {
      messageBoardService: messageBoardService,
      currentYear: new Date().getUTCFullYear()
    });
  }
}());
