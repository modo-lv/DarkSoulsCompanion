angular? .module "dsc.common" .service "itemUpgradeSvc" (itemService) ->
	new ItemUpgradeService itemService

class ItemUpgradeService

	(@itemService) ->


	getBaseItemIdFrom : (id) !~>
		return id - (id % 100)


module?.exports = ItemUpgradeService