_ <-! describe "inventory-service"

var svc, storageSvc, itemIndexSvc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	itemIndexSvc := new (testRequire "modules/items/item-index-service") edSvc
	svc := new (testRequire "modules/pc/inventory-service") storageSvc, itemIndexSvc, $q

	edSvc.loadJsonReturnValue = [
		{
			\uid : \weapon1
			\name : "Test weapon"
			\id : 1
			\itemType : \weapon
		}
	]
	itemIndexSvc.loadAllEntries!


it "should create models for loaded items", (done) !->
	indexEntry =
		\id : 1234
		\itemType : \armor
		\uid : \armor1234
		\name : "Not important"

	storageEntry =
		\uid : \armor1234
		\amount : 1

	edSvc.loadJsonReturnValue = [ indexEntry ]

	itemIndexSvc
	.clear!
	.loadAllEntries!
	.then ->
		storageSvc.loadReturnValue = [ storageEntry ]
		svc.load!
	.then (inventory) !->
		expect inventory
			.to.have.length 1

		expect inventory.0
			.to.be.an.instanceof svc._models.InventoryItem
			.and.to.have.property \uid, \armor1234

		done!
	.catch done


it "should populate items with names and types when loading inventory", (done) ->
	index = [
		{ \uid : "armor1", \name : "Armor One", \itemType : \armor }
		{ \uid : "weapon1", \name : "Weapon One", \itemType : \weapon }
	]

	sample = [
		{ \uid : "armor1", \amount : 2}
		{ \uid : "weapon1", \amount : 4}
	]

	edSvc.loadJsonReturnValue = index
	itemIndexSvc.clear!
	storageSvc.loadReturnValue = sample

	svc.load!
	.then (inventory) !->
		expect(inventory).to.have.length 2
		expect(inventory.0).to.have.property \name, "Armor One"
		expect(inventory.1).to.have.property \name, "Weapon One"
		done!
	.catch done


it "should correctly remove and re-add an item", (done) !->
	sample = { \uid : "weapon1", \amount : 1 }

	storageSvc.loadReturnValue = [ sample ]

	svc.load!
	.then (inv) ->
		item = inv.0
		svc.remove item
	.then (entry) ->
		svc.add entry
	.then (entry) ->
		expect entry .to.have.properties sample
		done!
	.catch done


it "should correctly add and remove an item", (done) !->
	item = { \uid : "weapon1", \amount : 1 }

	storageSvc.loadReturnValue = []

	svc
	.load!
	.then (inv) ->
		svc.add item
	.then (entry) ->
		svc.remove entry
	.then (entry) ->
		expect svc.load!
			.to.eventually.have.length 0
			.notify done
	.catch done