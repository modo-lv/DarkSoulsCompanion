angular? .module "dsc" .service "itemUpgradeSvc" (externalDataSvc) ->
	new ItemUpgradeService externalDataSvc

class ItemUpgradeService

	(@externalDataSvc) ->
		# Holds the upgrade data for weapons and armor
		@_upgrades = {}

		# Holds the material set info for upgrades
		@_materialSets = []


	getBaseIdFrom : (id) !~>
		return id - @getUpgradeLevelFrom id


	getUpgradeLevelFrom : (id) !~>
		return id % 100


	getBaseItemIdOf : (item) ~>
		@getBaseIdFrom item.id


	/**
	 * Get the upgrade model for a given weapon at a given upgrade level
	 * @returns Promise, resolved with the upgrade (or null if nothing found)
	 */
	findUpgradeFor : (item, level) ~>
		@loadAllUpgrades item.itemType .then (upgrades) ~>
			upgrades |> find ~> (it.id == @getBaseIdFrom(item.upgradeId) + level)


	/**
	 * Find the materials required to upgrade a given item using a given upgrade model.
	 * @returns Promise that is resolved with the material data.
	 */
	findUpgradeMaterialsFor : (item, upgrade) !~>
		if not (item? and upgrade?)
			throw new Error "Can't find upgrade materials, either item or upgrade is unset."

		if item.matSetId < 0 then
			$q.defer!
				..resolve null
				return ..promise

		return @loadAllMaterialSets!.then ~>
			@_materialSets |> find ~> (it.id == @getBaseIdFrom(item.matSetId) + upgrade.matSetId)


	are : (materials) ~>
		enoughToUpgrade : (item, level) ~>
			@findUpgradeFor item, level
			.then (upgrade) ~>
				if not upgrade?
					return false
				@findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				if materialSet == false
					return null
				#if not materialSet?
					#console.log "Failed to find material set for", {} <<< item, level, "upgrade is", upgrade
				return materials |> any -> (it.id == materialSet.matId and it.amount >= materialSet.matCost)


	deductFrom : (materials) ~>
		costOfUpgrade : (item, level) ~>
			@findUpgradeFor item, level
			.then (upgrade) ~>
				@findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				#console.log "Deducting #{materialSet.matId} x #{materialSet.matCost} from", {} <<< materials, "for item", item, "level", level
				(materials |> find (.id == materialSet.matId)).amount -= materialSet.matCost

				return { matCost : materialSet.matCost, matId : materialSet.matId }


	/**
	 * Asynchronously loads all information on material sets required for upgrades
	 * @returns Promise that will be resolved with the material set data.
	 */
	loadAllMaterialSets : !~>
		if not @_materialSets.$promise?
			@_materialSets = @externalDataSvc.loadJson "/modules/items/content/material-sets.json", false

		return @_materialSets.$promise


	/**
	 * Load information on all upgrades for a given item type
	 * @returns Promise resolved with the upgrade data
	 */
	loadAllUpgrades : (itemType) ~>
		itemType |> @ensureItCanBeUpgraded

		if not @_upgrades.[][itemType].$promise?
			@_upgrades.[itemType] = @externalDataSvc.loadJson "/modules/items/content/#{itemType}-upgrades.json", false

		return @_upgrades.[itemType].$promise


	ensureItCanBeUpgraded : (item) !~>
		if not item?
			throw new Error "Item / item type not provided."
		if typeof item == \string
			item = { itemType : item }
		if not (item |> @canBeUpgraded)
			throw new Error "Only weapons and armors can be upgraded, this is a [#{item.itemType}]."


	upgradeLevelOf : (item) ~>
		item.id % 100


	isUpgraded : (item) ~>
		(@upgradeLevelOf item) > 0


	canBeUpgraded : (item) ~>
		item.itemType == \weapon or item.itemType == \armor


	canBeUpgradedFurther : (item) ~>
		if not @canBeUpgraded item
			return false

		return @findUpgradeFor item, @upgradeLevelOf item
		.then (upgrade) ~> upgrade?


	apply : (upgrade) ~>
		if not upgrade?
			throw new Error "No upgrade data provided."
		to : (item) !~>
			item |> @ensureItCanBeUpgraded

			item
				..id += (upgrade.\id % 100)
				..upgradeId = upgrade.\id
				..matSetId += upgrade.\matSetId

			for field in [
				\defModPhy
				\defModMag
				\defModFir
				\defModLit
				\defModTox
				\defModBlo
				\defModCur
			]
				item.[field.replace 'Mod', ''] *= upgrade.[field]

			switch item.\itemType
			case \weapon
				for field in [
					\atkModPhy
					\atkModMag
					\atkModFir
					\atkModLit
					\bonusModStr
					\bonusModDex
					\bonusModInt
					\bonusModFai
				]
					item.[field.replace 'Mod', ''] *= upgrade.[field]
			case \armor
				for field in [\defModStrike \defModSlash \defModThrust ]
					item.[field.replace 'Mod', ''] *= upgrade.[field]

			return item

module?.exports = ItemUpgradeService