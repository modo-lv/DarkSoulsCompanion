angular? .module "dsc" .service "itemUpgradeSvc" (itemSvc) ->
	new ItemUpgradeService itemSvc

class ItemUpgradeService

	(@itemSvc) ->


	getBaseItemIdFrom : (id) !~>
		return id - (id % 100)


	getBaseItemIdOf : (item) ~>
		@getBaseItemIdFrom item.id


	/**
	 * Find the un-upgraded base version of a given item
	 * @returns Promise that resolves with the found base item
	 */
	findBaseItemOf : (item) ~>
		@itemSvc.findItem item.itemType, ~> it.id == @getBaseItemIdOf item


module?.exports = ItemUpgradeService