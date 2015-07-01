$routeProvider <-! angular .module "dsc" .config

$routeProvider
	.when '/guide/:section', {
		templateUrl : 'modules/guide/view.html'
		controller : 'GuideController'
	}
	.when '/items', {
		templateUrl : 'modules/items/view.html'
		controller : 'ItemsController'
	}
	.when '/inventory', {
		templateUrl : 'modules/inventory/view.html'
		controller : 'InventoryController'
	}
	.when '/stats', {
		templateUrl : 'modules/pc/view.html'
		controller : 'PcController'
	}
	.when '/w-calc', {
		templateUrl : 'modules/w-calc/view.html'
		controller : 'WeaponCalcController'
	}
	.otherwise {
		redirectTo : '/guide/intro'
	}
