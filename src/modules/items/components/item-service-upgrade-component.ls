class ItemServiceUpgradeComponent
	(@_itemSvc, @_externalDataSvc, @_itemIndexSvc, @_inventorySvc, @$q) ->
		# Holds the upgrade data for weapons and armor
		@_upgrades = {}

		# Holds the material set info for upgrades
		@_materialSets = []


	clearUpgrades : !~>
		for type in [\weapon \armor]
			@_upgrades.[][type].length = 0
			delete @_upgrades.[type].$promise
		return this

	clearMaterialSets : !~>
		@_materialSets.length = 0
		delete @_materialSets.$promise
		return this


	getBaseIdFrom : (id) !~>
		return id - @getUpgradeLevelFrom id


	getUpgradeLevelFrom : (id) !~>
		return id % 100


	getBaseItemIdOf : (item) ~>
		@getBaseIdFrom item.id


	findBaseItem : (item) ~>
		@_itemSvc.findItem item.itemType, ~> (it.id == @getBaseIdFrom item.id)


	/**
	 * Get the upgrade model for a given weapon at a given upgrade level
	 * @returns Promise, resolved with the upgrade (or null if nothing found)
	 */
	findUpgradeFor : (item, level) ~>
		@loadAllUpgrades item.itemType .then (upgrades) ~>
			if item.matSetId < 0
				return null
			#console.log "upgrades |> find ~> (it.id == #{@getBaseIdFrom(item.upgradeId)} + #{level})"
			upgrades |> find ~> (it.id == @getBaseIdFrom(item.upgradeId) + level)


	/**
	 * Find the materials required to upgrade a given item using a given upgrade model.
	 * @returns Promise that is resolved with the material data.
	 */
	findUpgradeMaterialsFor : (item, upgrade) !~>
		if not (item? and upgrade?)
			throw new Error "Can't find upgrade materials, either item or upgrade is unset."

		if item.matSetId < 0 then
			@$q.defer!
				..resolve null
				return ..promise

		return @loadAllMaterialSets!.then ~>
			@_materialSets |> find ~> (it.id == @getBaseIdFrom(item.matSetId) + upgrade.matSetId)


	are : (materials) ~>
		#if @_debugLog
		#	console.log "Materials:", materials
		enoughToUpgrade : (item, level) ~>
			@findUpgradeFor item, level
			.then (upgrade) ~>
				if not upgrade?
					return false
				@findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				if materialSet == null
					return false
				if not materialSet?
					console.log "Failed to find material set for", {} <<< item, level

				if materialSet.matId < 0 or materialSet.matCost < 0
					return true

				return materials |> any -> (it.id == materialSet.matId and it.amount >= materialSet.matCost)


	deductFrom : (materials) ~>
		costOfUpgrade : (item, level) ~>
			@findUpgradeFor item, level
			.then (upgrade) ~>
				@findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				if materialSet.matId >= 0 and materialSet.matCost >= 0
					#console.log "Deducting #{materialSet.matId} x #{materialSet.matCost} from", {} <<< materials, "for item", item, "level", level
					material = materials |> find (.id == materialSet.matId)
					if not material?
						console.log materialSet.matId, materials
					material.amount -= materialSet.matCost

				return { matCost : materialSet.matCost, matId : materialSet.matId }


	/**
	 * Asynchronously loads all information on material sets required for upgrades
	 * @returns Promise that will be resolved with the material set data.
	 */
	loadAllMaterialSets : !~>
		if not @_materialSets.$promise?
			@_materialSets = @_externalDataSvc.loadJson "/modules/items/content/material-sets.json", false

		return @_materialSets.$promise


	/**
	 * Load information on all upgrades for a given item type
	 * @returns Promise resolved with the upgrade data
	 */
	loadAllUpgrades : (itemType) ~>
		itemType |> @ensureItCanBeUpgraded

		if not @_upgrades.[][itemType].$promise?
			@_upgrades.[itemType] = @_externalDataSvc.loadJson "/modules/items/content/#{itemType}-upgrades.json", false

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
		if (not @canBeUpgraded item) or item.weaponType == \Magic or item.matSetId < 0 or item.upgradeId < 0
			return false

		return @findUpgradeFor item, (@upgradeLevelOf item) + 1
			.then (upgrade) ~>
				if @_debugLog and not upgrade?
					console.log "Failed to find an upgrade for item (id: #{item.id}) at level #{@upgradeLevelOf item}"
				upgrade?


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
				[\defPhy	\defModPhy]
				[\defMag	\defModMag]
				[\defFir	\defModFir]
				[\defLit	\defModLit]
				[\defTox	\defModTox]
				[\defBlo	\defModBlo]
				[\defCur	\defModCur]
			]
				item.[field.0] *= (upgrade.[field.1] ? 1)

			switch item.\itemType
			| \weapon =>
				for field in [
					[ \atkPhy \atkModPhy ]
					[ \atkMag \atkModMag ]
					[ \atkFir \atkModFir ]
					[ \atkLit \atkModLit ]
					[ \bonusStr \bonusModStr ]
					[ \bonusDex \bonusModDex ]
					[ \bonusInt \bonusModInt ]
					[ \bonusFai \bonusModFai ]
					[ \defSta \defModSta ]
				]
					item.[field.0] *= (upgrade.[field.1] ? 1)
			| \armor =>
				for field in [
					[\defStrike \defModStrike]
					[\defSlash \defModSlash]
					[\defThrust \defModThrust]
				]
					item.[field.0] *= (upgrade.[field.1] ? 1)

			return item


	/**
	 * Find all upgrades that can be applied to a given item,
	 * within the limits of what is available to the user
	 */
	findAllAvailableUpgradesFor : (item) ~>
		item |> @ensureItCanBeUpgraded

		if not item.id?
			throw new Error "Can't find upgrades for an item with no ID."

		if item.id < 0 or item.upgradeId < 0 then
			@$q.defer!
				..resolve []
				return ..promise

		upgradeList = []
		maxUpgrades = if item.itemType == \weapon then 15 else 10

		@_inventorySvc.load!
		.then (inventory) ~>
			materials = inventory |> filter (.itemType == \item ) |> map -> {} <<< it

			promise = @$q (resolve, reject) !-> resolve!

			canKeepUpgrading = true

			if @_debugLog
				console.log "Item's current upgrade level is #{@getUpgradeLevelFrom item.id}"

			for level from (@getUpgradeLevelFrom item.id) + 1 to maxUpgrades
				((materials, level) !~>
					promise := promise
					.then ~>
						if not canKeepUpgrading then return null
						if @_debugLog
							console.log "Checking upgrade level #{level}"

						@$q.all [
							@.canBeUpgradedFurther item
							@.are materials .enoughToUpgrade item, level
						]
					.then (canUpgrade) !~>
						if @_debugLog and canUpgrade?
							console.log "Can upgrade further: #{canUpgrade.0}"
							console.log "Enough materials: #{canUpgrade.1}"

						if not (canUpgrade?.0 and canUpgrade?.1)
							materials.length = 0
							canKeepUpgrading := false
							return null

						if canUpgrade := canUpgrade.0 + canUpgrade.1
							return @$q.all [
								@_itemSvc.getUpgraded item, level
								@deductFrom materials .costOfUpgrade item, level
							]
					.then (result) !~>
						upItem = result?.0
						cost = result?.1
						if upItem?
							totalCost = materials.[]totalCost
							costEntry = totalCost |> find (.matId == cost.matId)
							if not costEntry?
								costEntry = {
									matId : cost.matId
									matCost : 0
								}
								totalCost.push costEntry

							costEntry.matCost += cost.matCost
							upItem
								..totalCost = totalCost |> map -> {} <<< it
								# Upgrade level counting from the starting level as it's in the inventory
								..upgradeLevel = level - @getUpgradeLevelFrom item.id

							upgradeList.push upItem
				) materials, level
			return promise
		.then ->
			#console.log upgradeList
			return upgradeList

module?.exports = ItemServiceUpgradeComponent