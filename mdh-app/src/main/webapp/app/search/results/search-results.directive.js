(function() {
  'use strict';

  /**
   * angular element directive; displays search results.
   *
   * Binds a `link` property to each result object, based on the result of the function passed to the `link` attribute. If no function is passed a default function is provided. The resulting `link` property will have the form `/detail?uri={{ result.uri }}`
   *
   * attributes:
   *
   * - `search`: a reference to the search results object from {@link MLSearchContext#search}
   * - `link`: optional. a function that accepts a `result` object, and returns a URL to be used as the link target in the search results display
   * - `click`: optional. a function that accepts a `result` object. if present, will be used as the click-handler for each result (`link` will be ignored)
   * - `template`: optional. A URL referencing a template to be used with the directive. If empty, the default bootstrap template will be used.
   *
   * Example:
   *
   * ```
   * <ml-results results="ctrl.response.results" link="ctrl.linkTarget(result)"></ml-results>```
   *
   * @namespace ml-results
   */
  angular.module('app.search')
    .directive('searchResults', searchResults)
    .controller('ResultsController', ResultsController);

  ResultsController.$inject = ['$scope'];

  function searchResults() {
    return {
      restrict: 'E',
      controller: 'ResultsController',
      controllerAs: 'ctrl',
      scope: {
        results: '=',
        click: '&',
        link: '&',
        label: '&',
        toggleSort: '&'
      },
      templateUrl: template,
      link: link
    };
  }

  function template(element, attrs) {
    var url;

    if (attrs.template) {
      url = attrs.template;
    } else {
      url = '/templates/ml-results.html';
    }

    return url;
  }

  function link(scope, element, attrs) {
    scope.shouldClick = !!attrs.click;

    // default link fn
    if ( !attrs.link ) {
      scope.link = function(result) {
        // directive methods require objects
        return '/detail?uri=' + encodeURIComponent( result.result.uri );
      };
    }

    // default label fn
    if ( !attrs.label ) {
      scope.label = function(result) {
        // directive methods require objects
        return _.last( result.result.uri.split('/') );
      };
    }

    scope.$watch('results', function(newVal, oldVal) {
      _.each(newVal, function(result) {
        result.link = scope.link({ result: result });
        result.label = scope.label({ result: result });
      });
    });
  }

  function ResultsController($scope) {

    //Sum Income Summary
    $scope.totalIncome = function (income) {
      var incomeTotal = 0;
      if(income != null) {
        income.map(function (item, index) {
          incomeTotal += item.IncomeAmount;
        });
      }
      return incomeTotal;
    };

    //Sum Work Hours
    $scope.totalWorkHours = function (income) {
      var wrkTotal = 0;
      if(income != null) {
        income.map(function (item, index) {
          wrkTotal += item.IncomeWorkHoursNumber
        });
      }
      return wrkTotal;
    };

    $scope.flagPregDueDate = function (pregDate) {
      if(pregDate != null) {
        var startDateTime = Date.parse(pregDate);
        var lastYear = new Date();
        lastYear.setMonth(lastYear.getMonth() - 12);
        var lastYearTime = lastYear.getTime();
        if(startDateTime >= lastYearTime) {
          return "attention-cell";
        }
      }
      return null;
    };

    $scope.flagIncome = function (income) {
      if(income != null) {
        if($scope.totalIncome(income) <= 217.50) {
          return "attention-cell";
        }
      }
      return null;
    };

    $scope.flagWorkHours = function (income) {
      if(income != null) {
        if($scope.totalWorkHours(income) < 30) {
          return "attention-cell";
        }
      }
      return null;
    };


  }
}());
