angular? .module "dsc" .service "weapon-finder-service" (itemSvc, inventorySvc) ->
	return new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_inventorySvc) ->
		@params = {}





	findFittingWeapons : ~>
		@_inventorySvc.findRealItemsByType \weapon
		.then (weapons) !~>
			# Discard any that don't meet requirements

			return weapons


module? .exports = WeaponFinderService