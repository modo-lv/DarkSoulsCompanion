$routeProvider <-! angular .module "dsc" .config

$routeProvider
	.when '/tracker/:area', {
		templateUrl : 'modules/tracker/tracker-view.html'
		controller : 'trackerController'
	}
	.when '/items', {
		templateUrl : 'modules/items/view.html'
		controller : 'ItemsController'
	}
	.when '/pc', {
		templateUrl : 'modules/pc/pc-view.html'
		controller : 'pcController'
	}
	.when '/weapon-finder', {
		templateUrl : 'modules/weapon-finder/weapon-finder-view.html'
		controller : 'weaponFinderController'
	}
	.when '/armor-finder', {
		templateUrl : 'modules/armor-finder/armor-finder-view.html'
		controller : 'armorFinderController'
	}
	.otherwise {
		redirectTo : '/tracker/asylum'
	}
