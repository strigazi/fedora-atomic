(function(exports) {
    'use strict';

    var fatomicControllers = angular.module('fatomicControllers', []);

    var ROOT = '/';

    fatomicControllers.controller('fatomicHomeCtrl', function($scope, $http) {
        var builds = [];

	console.log("Initializing");

        $http.get(ROOT + 'autobuilder-status.json').success(function(status) {
            var text;
            if (status.running.length > 0)
                text = 'Running: ' + status.running.join(' ') + '; load=' + status.systemLoad[0];
            else
                text = 'Idle, awaiting packages';

            $scope.runningState = text;
        });

	let latestSmoketestPath = ROOT + 'results/tasks/smoketest';
        var productsBuiltPath = latestSmoketestPath + '/products-built.json';
	console.log("Retrieving products-built.json");
	$http.get(productsBuiltPath).success(function(data) {
	    var trees = data['trees'];
	    for (var ref in trees) {
		var treeData = trees[ref];
		var refUnix = ref.replace(/\//g, '-');
		treeData.refUnix = refUnix;
		treeData.screenshotUrl = latestSmoketestPath + '/smoketest/work-' + refUnix + '/screenshot-final.png';
	    }
	    $scope.trees = trees;
	});
    });

})(window);
