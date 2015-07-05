_ <-! describe "inventory-service"

var svc, storageSvc, itemIndexSvc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	itemIndexSvc := new (testRequire "modules/items/item-index-service") edSvc
	svc := new (testRequire "modules/inventory/inventory-service") storageSvc, itemIndexSvc


it "should create models for loaded items", !->
	sample =
		\id : 1234
		\itemType : \armor
		\uid : \armor1234
		\name : "Not important"

	storageSvc.loadReturnValue = [ sample ]

	expect(svc.inventory)
		.to.have.length.above 0

	expect(svc.inventory.0)
		.to.be.an.instanceof svc._models.InventoryItem
		.and.to.have.property \uid, \armor1234


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
	storageSvc.loadReturnValue = sample

	svc.load!

	expect(svc.inventory).to.have.length 2

	svc.inventory.0.$promise
	.then ->
		svc.inventory.1.$promise
	.then ->
		expect(svc.inventory.0).to.have.property \name, "Armor One"
		expect(svc.inventory.1).to.have.property \name, "Weapon One"
		done!
	.catch done