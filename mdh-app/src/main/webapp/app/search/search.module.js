(function () {
  'use strict';

  angular.module('app.search', ['ml.search', 'app.user', 'app.snippet', 'ml.esri-maps',
    'search.personhelper', 'search.casehelper', 'report.abawd', 'search.params']);
}());
