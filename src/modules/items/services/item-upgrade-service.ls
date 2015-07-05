angular? .module "dsc" .service "itemUpgradeSvc" (externalDataSvc) ->
	new ItemUpgradeService externalDataSvc

class ItemUpgradeService

	(@externalDataSvc) ->
		# Holds the upgrade data for weapons and armor
		@_upgrades = {}


	getBaseItemIdFrom : (id) !~>
		return id - (id % 100)


	getBaseItemIdOf : (item) ~>
		@getBaseItemIdFrom item.id


	/**
	 * Get the upgrade model for a given weapon at a given upgrade level
	 * @returns Promise, resolved with the upgrade (or null if nothing found)
	 */
	findUpgradeFor : (item, level) ~>
		@getAllUpgrades item.itemType .then (upgrades) ->
			upgrades |> find (.id == item.upgradeId + level)


	/**
	 * Load information on all upgrades for a given item type
	 * @returns Promise resolved with the upgrade data
	 */
	getAllUpgrades : (itemType) ~>
		if itemType != \weapon and itemType != \armor
			throw new Error "Only weapons and armor can be upgraded."

		if not @_upgrades.[][itemType].$promise?
			@_upgrades.[itemType] = @externalDataSvc.loadJson "/modules/items/content/#{itemType}-upgrades.json", false

		return @_upgrades.[itemType].$promise




module?.exports = ItemUpgradeService