angular? .module "dsc" .service "inventorySvc" (itemSvc, storageSvc, itemIndexSvc, notificationSvc, $q) ->
	new InventorySvc ...

class InventorySvc

	(@_itemSvc, @_storageSvc, @_itemIndexSvc, @_notificationSvc, @$q) ->
		@_inventory = []
		@_models = require './models/inventory-models'


	save : !~>
		data = []
		for item in @_inventory
			data.push {
				\uid : item.uid
				\amount : item.amount
			}
		@_storageSvc.save 'inventory', data


	load : ~>
		if not @_inventory.$promise?
			@clear!
			promises = []
			for data in (@_storageSvc.load 'inventory') ? []
				promise = let data = data
					item = new @_models.InventoryItem data
					@_itemIndexSvc.findEntryByUid(data.uid)
					.then (indexEntry) !~>
						item.useDataFrom indexEntry
						@_inventory.push item
						return item

				promises.push promise

			@_inventory.$promise = @$q.all promises .then ~> @_inventory

		return @_inventory.$promise


	findItemByUid : (uid) ~>
		@load!.then (inventory) ~>
			inventory |> find (.uid == uid)


	/**
	 * Return all items the inventory having a specific itemType
	 */
	findItemsByType : (type, subType = null) ~>
		@load!
		.then (inventory) ~>
			inventory |> filter (.itemType == type)
		.then (filtered) ~>
			@$q.all(filtered |> map ~> @_itemSvc.findAnyItemByUid it.uid)


	createInventoryItemFrom : (item, amount = 1) ~>
		new @_models.InventoryItem
			..useDataFrom item
			..amount = amount


	addAll : (items) ~>
		invEntries = items |> map ~> if not it.amount? then { item : it, amount : 1 } else it

		promises = []

		for entry in invEntries
			promises.push @add entry.item, entry.amount, false
		@$q.all promises .then !~>
			itemList = invEntries
				|> map ~> "#{if it.amount > 1 then it.amount + " of " else ""}<strong>#{it.item.name}</strong>"
				|> join ', '

			@_notificationSvc.addInfo "Added #{itemList} to the inventory."


	hasItemWithName : (name) ~>
		@load! .then ~> it |> any (.name == name)


	addAllByName : (namesAndAmounts) ~>
		promises = []
		for entry in namesAndAmounts
			let entry = entry
				promises.push @addByName entry.name, entry.amount, false

		@$q.all promises .then (items) !~>
			itemList = items
				|> filter ~> it?
				|> map ~> "<strong>#{it.name}</strong>"
				|> join ', '

			if itemList.length > 0
				@_notificationSvc.addInfo "Added #{itemList} to the inventory."


	addByName : (itemName, amount = 1, notify = true) ~>
		@_itemIndexSvc.findEntryByName itemName
		.then (item) ~>
			if not item? then
				@_notificationSvc.addError "Could not find item named '<strong>#{itemName}</strong>', cannot add to inventory."
				return null
			@add item, amount, notify


	add : (item, amount = 1, notify = true) ~>
		@findItemByUid item.uid
		.then (invItem) !~>
			if invItem?
				invItem.amount += amount
			else
				invItem = @createInventoryItemFrom item, amount
					.. |> @_inventory.push

			if notify
				@_notificationSvc.addInfo "Added #{if amount > 1 then amount + " of " else ""}<strong>#{invItem.name}</strong> to the inventory."

			@save!
			return invItem


	remove : (item, amount = 1) ~>
		@findItemByUid item.uid
		.then (entry) !~>
			if not entry?
				throw new Error "Failed to remove the above item because couldn't find it in the inventory."

			entry.amount = if amount == true then 0 else entry.amount -= amount

			if entry.amount < 1
				@_inventory.splice (@_inventory.indexOf entry), 1

			@save!
			return entry



	clear : !~>
		@_inventory.length = 0
		delete @_inventory.$promise
		return this



	/**
	 * Find all upgrades that can be applied to a given item,
	 * within the limits of what is available to the user
	 */
	findAllAvailableUpgradesFor : (item) ~>
		up = @_itemSvc.upgradeComp
		item |> up.ensureItCanBeUpgraded

		if not item.id?
			throw new Error "Can't find upgrades for an item with no ID."

		if item.id < 0 or item.upgradeId < 0 then
			@$q.defer!
				..resolve []
				return ..promise

		upgradeList = []
		maxUpgrades = if item.itemType == \weapon then 15 else 10

		@load!
		.then (inventory) ~>
			materials = inventory |> filter (.itemType == \item ) |> map -> {} <<< it

			promise = @$q (resolve, reject) !-> resolve!

			canKeepUpgrading = true

			if @_debugLog
				console.log "Item's current upgrade level is #{up.getUpgradeLevelFrom item.id}"

			for level from (up.getUpgradeLevelFrom item.id) + 1 to maxUpgrades
				((materials, level) !~>
					promise := promise
					.then ~>
						if not canKeepUpgrading then return null
						if @_debugLog
							console.log "Checking upgrade level #{level}"

						@$q.all [
							up.canBeUpgradedFurther item
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
								..upgradeLevel = level - up.getUpgradeLevelFrom item.id

							upgradeList.push upItem
				) materials, level
			return promise
		.then ->
			#console.log upgradeList
			return upgradeList


	are : (materials) ~>
		up = @_itemSvc.upgradeComp
		#if @_debugLog
		#	console.log "Materials:", materials
		enoughToUpgrade : (item, level) ~>
			up.findUpgradeFor item, level
			.then (upgrade) ~>
				if not upgrade?
					return false
				up.findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				if materialSet == null
					return false
				if not materialSet?
					console.log "Failed to find material set for", {} <<< item, level

				if materialSet.matId < 0 or materialSet.matCost < 0
					return true

				return materials |> any -> (it.id == materialSet.matId and it.amount >= materialSet.matCost)


	deductFrom : (materials) ~>
		up = @_itemSvc.upgradeComp
		costOfUpgrade : (item, level) ~>
			up.findUpgradeFor item, level
			.then (upgrade) ~>
				up.findUpgradeMaterialsFor item, upgrade
			.then (materialSet) ~>
				if materialSet.matId >= 0 and materialSet.matCost >= 0
					#console.log "Deducting #{materialSet.matId} x #{materialSet.matCost} from", {} <<< materials, "for item", item, "level", level
					material = materials |> find (.id == materialSet.matId)
					if not material?
						console.log materialSet.matId, materials
					material.amount -= materialSet.matCost

				return { matCost : materialSet.matCost, matId : materialSet.matId }



module?.exports = InventorySvc