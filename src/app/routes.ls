$routeProvider <-! angular .module "dsc" .config

$routeProvider
	.when '/guide/:section', {
		templateUrl : 'modules/guide/guide-view.html'
		controller : 'GuideController'
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
	.when '/armor-calc', {
		templateUrl : 'modules/armor-calc/armor-calc-view.html'
		controller : 'ArmorCalcController'
	}
	.otherwise {
		redirectTo : '/guide/intro'
	}
