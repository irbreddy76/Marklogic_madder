(function () {
  'use strict';

  angular.module('report.abawd', ['ml.common'])
    .service('abawdHelper', AbawdHelper);

  AbawdHelper.$inject = ['$rootScope', '$filter'];

  function AbawdHelper($rootScope, $filter) {
    var reportObject = {};

    function getReport() {
      return reportObject;
    }

    function updateReport(report) {
      reportObject = report;
    }

    function clearReport() {
      reportObject = {};
    }

    function getReportQueryParams(report) {
      // builds parameters to call a restful service that will return
      // a structured query that can be passed to the search API for
      // ABAWD reports

      var params = {
        'rs:cert-period': '2016-08',
      };

      return params;
    }

    return {
      getReport: getReport,
      updateReport: updateReport,
      clearReport: clearReport,
      getReportQueryParams: getReportQueryParams
    };
  }
}());
