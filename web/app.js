(function(exports) {
    'use strict';

    var fatomic = angular.module('fatomic', [
        'ngRoute',
        'fatomicControllers',
    ]);

    fatomic.config(['$routeProvider', function($routeProvider) {
        $routeProvider.
            when('/', {
                templateUrl: 'partials/home.html'
	    }).
            when('/background', {
                templateUrl: 'partials/background.html'
            }).
            when('/build-status', {
                templateUrl: 'partials/build-status.html'
            }).
            when('/implementation', {
                templateUrl: 'partials/implementation.html'
            }).
            when('/installation', {
                templateUrl: 'partials/installation.html'
            }).
            otherwise({
                redirectTo: 'partials/unknown.html',
            });
    }]);

})(window);
