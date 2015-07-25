angular? .module "dsc" .service "itemSvc" (externalDataSvc, itemIndexSvc, $q) -> new ItemService ...

class ItemService
	@WeaponStats = [\str \dex \int \fai]
	@AttackTypes = [\phy \mag \fir \lit]
	@AllAttackTypes = @AttackTypes ++ [\blo \tox \div \occ]
	@DefenseTypes = @AllDefenseTypes = @AttackTypes ++ [\blo \tox \cur \sta]
	@DefPhyTypes = [\sla \str \thr]

	@AttackTypeNames = [
		\Physical \Magic \Fire \Lightning
	]

	@AllAttackTypeNames = @AttackTypeNames ++ [
		\Bleed \Poison \Divine \Occult
	]

	@DefenseTypeNames = @AttackTypeNames ++ [
		\Bleed \Poison \Curse \Poise
	]

	(@_externalDataSvc, @_itemIndexSvc, @$q) ->
		@.upgradeComp = new (require './components/item-service-upgrade-component')

		@.upgradeComp.@@.apply @.{}upgradeComp, [this] ++ (& |> map -> it)

		# Item data storage containing
		@_storage = {}

		@_models = require './models/item-models'


	clear : (itemType) !~>
		if not itemType?
			@_storage = {}
		else
			@_storage.[itemType].length = 0
			delete @_storage.[itemType].$promise
		return this


	/**
	 * Return the first item matching a given filter
	 * @param itemType String type of item to find.
	 * @param filterFn Function Filter function
	 * @return Promise that resolves with the found item, or null if nothing found.
	 */
	findItem : (itemType, filterFn) ~>
		if typeof itemType != \string
			throw new Error "Item type is invalid or not provided"
		@loadAllItems itemType .then (items) ~>
			item = items |> find filterFn
			return item


	findItemById : (itemType, id) ~>
		@loadAllItems itemType
		.then (items) ~>
			item = items |> find (.id == id)
			if not item?
				throw new Error "Failed to find [#{itemType}] with ID [#{id}]."
			return item


	/**
	 * Finds any item, regardless of type, but can only
	 * check fields that are in the index.
	 */
	findAnyItemByUid : (uid) ~>
		@_itemIndexSvc.findEntryByUid(uid)
		.then (item) !~>
			if not item?
				throw new Error "Failed to find item with UID [#{uid}] in the item index."
			if @upgradeComp.isUpgraded item
				baseId = @upgradeComp.getBaseIdFrom item.id
				upLevel = @upgradeComp.getUpgradeLevelFrom item.id
				#console.log "Base ID: #{baseId}, upLevel: #{upLevel}"
				return ((item, baseId, upLevel) ~>
					@findItemById item.itemType, baseId
					.then (baseItem) ~>
						@getUpgraded baseItem, upLevel
				) item, baseId, upLevel
			else
				return @findItemById item.itemType, item.id


	/**
	 * Create a model from given item data
	 */
	createItemModelFrom : (data) ~>
		(switch data.itemType
		| \weapon => new @_models.Weapon
		| \armor => new @_models.Armor
		| \item => new @_models.Item
		| otherwise => throw new Error "Cannot create item model from data with .itemType == #{data.itemType}."
		).useDataFrom(data)


	/**
	 * Load item data of a given item type.
	 * @returns Promise or populated array, depending on returnPromise setting.
	 */
	loadAllItems : (itemType) !~>
		if not @_storage.[][itemType].$promise?
			@_storage.[itemType].$promise = @_externalDataSvc.loadJson "/modules/items/content/#{itemType}s.json"
			.then (itemData) ~>
				@loadAll itemType .from itemData

		return @_storage.[itemType].$promise


	loadAll : (itemType) ~>
		\from : (itemData) ~>
			@_storage.[][itemType]
			itemData |> each !~> @_storage.[itemType].push @createItemModelFrom it
			return @_storage.[itemType]


	getUpgraded : (item, level = true) ~>
		if level == true
			level = (@upgradeComp.getUpgradeLevelFrom item.id) + 1
		@upgradeComp.findUpgradeFor item, level
		.then (upgrade) !~>
			if not upgrade?
				#console.warn "Failed to find upgrade at level #{level} for item", item
				return null

			return (item |> @upgradeComp.findBaseItem)
			.then (baseItem) ~>
				@createItemModelFrom baseItem
			.then (newItem) ~>
				@upgradeComp .apply upgrade .to newItem
			.then (newItem) ~>
				@_itemIndexSvc.findEntryByUid(newItem.uid)
				.then (entry) ~>
					if not entry?
						console.log newItem
						throw new Error "Failed to find index entry for the above item"
					newItem.name = entry.name
					return newItem
			.then (newItem) ~>
				if newItem.itemType == \armor
					newItem.armorSet = (@_itemIndexSvc.findArmorSetFor newItem).name
				return newItem


module?.exports = ItemService