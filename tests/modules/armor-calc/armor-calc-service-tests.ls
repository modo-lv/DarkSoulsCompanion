_ <-! describe "armor-calc-service"

var svc, edSvc, invSvc, itemUpSvc, itemSvc, storageSvc, itemIndexSvc

beforeEach (done) !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	itemIndexSvc := new (testRequire 'modules/items/item-index-service') edSvc
	itemUpSvc := new (testRequire 'modules/items/item-upgrade-service') edSvc
	itemSvc := new (testRequire 'modules/items/item-service') edSvc, itemIndexSvc, itemUpSvc
	invSvc := new (testRequire 'modules/inventory/inventory-service') storageSvc, itemIndexSvc, $q
	svc := new (testRequire 'modules/armor-calc/armor-calc-service') invSvc, itemSvc, $q

	# Setup default data
	inventory = require './test-data/armor-calc-test-inventory.json'
	armors = require './test-data/armor-calc-test-armors.json'
	materialSets = require './test-data/armor-calc-material-sets.json'
	upgrades = require './test-data/armor-calc-upgrades.json'
	index = require './test-data/armor-calc-index.json'

	storageSvc.loadReturnValue = inventory


	edSvc.loadJsonReturnValue = materialSets
	itemUpSvc.loadAllMaterialSets!
	.then ->
		edSvc.loadJsonReturnValue = upgrades
		itemUpSvc.loadAllUpgrades \armor
	.then ->
		edSvc.loadJsonReturnValue = armors
		itemSvc.loadAllItems \armor
	.then ->
		edSvc.loadJsonReturnValue = index
		itemIndexSvc.loadAllEntries!
	.then ->
		done!



it "should correctly find potential armors", (done) !->
	svc.freeWeight = 3

	svc.findUsableArmors!
	.then (armors) !->
		expect armors .to.have.length 3
		for armor in armors
			expect armor .to.have.property \itemType, \armor
			expect armor .to.have.property \weight .at.most svc.freeWeight
		done!
	.catch done


it "should correctly generate armor combinations", (done) !->
	svc.freeWeight = 10

	# 4 slots * 2 possible armors each = 2*2*2*2 = 16 possible combinations
	expectedCount = 16

	svc.findUsableArmors!
	.then (armors) ->
		svc.findAllCombinationsOf armors
	.then (combinations) !->
		expect combinations
			.to.have.length expectedCount
		done!
	.catch done


