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
                templateUrl: 'partials/build-status.html',
                controller: 'fatomicHomeCtrl'
            }).
            when('/implementation', {
                templateUrl: 'partials/implementation.html'
            }).
            when('/installation', {
                templateUrl: 'partials/installation.html'
            }).
            when('/running-custom', {
                templateUrl: 'partials/running-custom.html'
            }).
            otherwise({
                redirectTo: 'partials/unknown.html',
            });
    }]);

})(window);
