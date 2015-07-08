_ <-! describe "armor-calc-service"

var svc, edSvc, invSvc, itemUpSvc, itemSvc, storageSvc, itemIndexSvc

beforeEach (done) !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	itemIndexSvc := new (testRequire 'modules/items/item-index-service') edSvc
	itemUpSvc := new (testRequire 'modules/items/item-upgrade-service') edSvc
	itemSvc := new (testRequire 'modules/items/item-service') edSvc, itemIndexSvc, itemUpSvc
	invSvc := new (testRequire 'modules/inventory/inventory-service') storageSvc, itemIndexSvc, $q
	svc := new (testRequire 'modules/armor-calc/armor-calc-service') invSvc, itemSvc, itemUpSvc, $q

	# Setup default data
	/*
	inventory = require './test-data/armor-calc-test-inventory.json'
	armors = require './test-data/armor-calc-test-armors.json'
	materialSets = require './test-data/armor-calc-material-sets.json'
	upgrades = require './test-data/armor-calc-upgrades.json'
	index = require './test-data/armor-calc-index.json'
	*/
	inventory = require './test-data/temp-inventory.json'
	armors = testRequire './modules/items/content/armors.json'
	materialSets = testRequire './modules/items/content/material-sets.json'
	upgrades = testRequire './modules/items/content/armor-upgrades.json'
	index = testRequire './modules/items/content/index.json'

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
		expect armors .to.have.length 22 #3
		for armor in armors
			expect armor .to.have.property \itemType, \armor
			expect armor .to.have.property \weight .at.most svc.freeWeight
		done!
	.catch done


it "should correctly generate armor combinations", (done) !->
	armors = [
		{
			\id : 100
			\name : "One"
			\weight : 1
			\armorType : \head
		}
		{
			\id : 200
			\name : "Two"
			\weight : 2
			\armorType : \hands
		}
		{
			\id : 300
			\name : "Three"
			\weight : 3
			\armorType : \chest
		}
		{
			\id : 400
			\name : "Four"
			\weight : 4
			\armorType : \legs
		}
	]

	svc.freeWeight = 4
	#svc._debugLog = true

	# 4 slots * 2 possible values each = 2*2*2*2 = 16 possible combinations
	# Weight limit 4 means:
	#   "Four" can't combine with any combination of the lighter three: -(2*2*2)
	#		except if all three are empties: +1
	# 		== -7
	#   "Three" can't combine with any combination of the lighter two: -(2*2)
	# 		except if one of them is empty +(1+1)
	# 		== -2
	# 16 - 7 - 2 = 7
	expectedCount = 7

	svc.findAllCombinationsOf armors
	.then (combinations) !->
		expect combinations
			.to.have.length expectedCount
		console.log combinations
		done!
	.catch done


it "should correctly calculate score for an armor combination", !->
	svc.{}params.{}modifiers.phy = 0.5

	combination =
		armors : [
			{
				"defPhy" : 100
			},
			{
				"defPhy" : 200
			},
			{
				"defPhy" : 200
			},
			{
				"defPhy" : 100
			}
		]

	expect svc.calculateScoreFor combination
		.to.equal 300


it "should correctly find all available upgrades for a piece of armor", (done) !->
	itemSvc.findItem \armor, (.id == 480000) # 11000)
	.then (armor) ->
		svc.findAllAvailableUpgradesFor armor
	.then (upgradeList) ->
		expect upgradeList .to.have.length 10 # 5
		done!
	.catch done


it "should set the total upgrade cost on found upgrades", (done) !->
	itemSvc.findItem \armor, (.id == 480000)
	.then (armor) ->
		svc.findAllAvailableUpgradesFor armor
	.then (upgradeList) ->
		#console.log (upgradeList |> first)
		expect upgradeList .to.have.length 10
		#expect (upgradeList |> first) .to.have
		done!
	.catch done


it "should find the best armor combination", (done) !->
	svc.freeWeight = 2

	params = {
		takeBest : 5
	}

	svc.findBestCombinations params
	.then (combs) ->
		console.log combs
		#for comb in combs
		#	console.log (comb.armors |> sortBy (.score) |> reverse |> map (.name))
		#expect true .to.be.false
		done!
	.catch done