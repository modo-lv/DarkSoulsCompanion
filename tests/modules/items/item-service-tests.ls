_ <-! describe "item-service"

var svc, edSvc, upgradeSvc, itemIndexSvc, inventorySvc, storageSvc, notifySvc

beforeEach !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	notifySvc := new (testRequire 'app/services/notification-service') {}
	itemIndexSvc := new (testRequire "modules/items/item-index-service") edSvc
	inventorySvc := new (testRequire "modules/pc/inventory-service") storageSvc, itemIndexSvc, notifySvc, $q
	svc := new (testRequire "modules/items/item-service") edSvc, itemIndexSvc, inventorySvc, $q
	upgradeSvc := svc.upgradeComp

	weapons = [{
		\id : 500
		\name : "Test weapon"
		\itemType : \weapon
		\atkPhy : 100
		\matSetId : 7200
		\upgradeId : 0
	}]
	edSvc.loadJsonReturnValue = weapons
	svc.loadAllItems \weapon

	# Setup common basic data
	upgrades = [
	{
		\id : 1
		\atkModPhy : 1.5
		\matSetId : 1
	}
	{
		\id : 2
		\atkModPhy : 2
		\matSetId : 2
	}
	]

	edSvc.loadJsonReturnValue = upgrades
	upgradeSvc.loadAllUpgrades \weapon

	entries = [
		{
			\id : 500
			\uid : \weapon500
			\itemType : \weapon
			\name : "Test weapon"
		}
		{
			\id : 501
			\uid : \weapon501
			\itemType : \weapon
			\name : "Test weapon +1"
		}
		{
			\id : 502
			\uid : \weapon502
			\itemType : \weapon
			\name : "Test weapon +2"
		}
	]

	edSvc.loadJsonReturnValue = entries
	itemIndexSvc.loadAllEntries!



it "should find an item by id", (done) !->
	sample =
		\id : 10013
		\name : "Sample item"
		\itemType : \item

	edSvc.loadJsonReturnValue = [ sample ]

	svc.clear!
	svc.findItem \item, (.id == 10013)
	.then (result) !->
		expect result
			.to.be.instanceof svc._models.Item
			.and.to.have.properties sample
		done!
	.catch done

	
it "should get the upgraded version of a given item", (done) !->
	weapon =
		\id : 500
		\upgradeId : 0
		\atkPhy : 100
		\itemType : \weapon
		\matSetId : 7200


	svc.getUpgraded weapon
	.then (upWeapon)!->
		expect upWeapon .to.have.properties {
			\id : 501
			\matSetId : 7201
			\upgradeId : 1
			\atkPhy : 150
			\itemType : \weapon
		}
		done!
	.catch done


it "should generate an item's upgraded version when seaching for it", (done) !->
	svc.findAnyItemByUid(\weapon501)
	.then (item) !->
		expect item .to.have.properties {
			\id : 501
			\itemType : \weapon
			\atkPhy : 150
		}
		done!
	.catch done


it "should correctly upgrade given an already upgraded item", (done) !->
	svc.findAnyItemByUid(\weapon501)
	.then (upItem) ->
		expect upItem .to.have.property \id, 501
		expect upItem .to.have.property \atkPhy, 150
		svc.getUpgraded upItem
	.then (nextItem) ->
		expect nextItem .to.have.property \id, 502
		expect nextItem .to.have.property \atkPhy, 200
		done!
	.catch done


it "should fetch real item data", (done) !->
	inventory = [
		{ itemType : \weapon , id : 100 , uid : \weapon100 }
		{ itemType : \weapon , id : 200 , uid : \weapon200 }
		{ itemType : \armor , id : 100 , uid : \armor100 }
		{ itemType : \item , id : 200 , uid : \item200 }
	]

	weapons = [
		{ itemType : \weapon , id : 100 , uid : \weapon100 , name : "Weapon One" }
		{ itemType : \weapon , id : 200 , uid : \weapon200 , name : "Weapon Two" }
	]

	storageSvc.loadReturnValue = inventory
	edSvc.loadJsonReturnValue = inventory
	itemIndexSvc.clear!.loadAllEntries!

	edSvc.loadJsonReturnValue = weapons
	svc.clear!.loadAllItems \weapon

	svc.findItemsFromInventory \weapon
	.then (items) !->
		expect items .to.have.length 2
		for item, index in items |> sortBy (.id)
			expect item .to.exist
			expect item .to.have.properties weapons.[index]
		done!
	.catch done