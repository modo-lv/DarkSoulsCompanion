_ <-! describe "item-service-upgrade-component"

var svc, edSvc, itemModels, upModels, itemSvc, inventorySvc, storageSvc, itemIndexSvc

beforeEach !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	itemIndexSvc := new (testRequire "modules/items/item-index-service") edSvc
	inventorySvc := new (testRequire "modules/pc/inventory-service") storageSvc, itemIndexSvc, $q
	itemSvc := new (testRequire "modules/items/item-service") edSvc, itemIndexSvc, inventorySvc, $q
	svc := itemSvc.upgradeComp
	itemModels := testRequire 'modules/items/models/item-models'
	upModels := testRequire 'modules/items/models/item-upgrade-models'


it "should correctly calculate the base item ID from an upgraded one", !->
	baseId = svc.getBaseIdFrom 103012
	expect baseId .to.equal 103000


it "should find the correct upgrade for an item", (done) !->
	item =
		\upgradeId : 10000
		\itemType : \weapon

	upgrade =
		\id : 10012

	edSvc.loadJsonReturnValue = [ upgrade ]

	expect svc.findUpgradeFor item, 12
		.to.eventually.equal upgrade
		.notify done


it "should apply an upgrade correctly", (done) !->
	itemModel = new itemModels.Weapon!
	upModel = new upModels.Weapon

	done!


it "should load upgrade data correctly", (done) !->
	upData =
		\id : 100

	edSvc.loadJsonReturnValue = [ upData ]

	expect svc.loadAllUpgrades \weapon
		.to.eventually.have.members [ upData ]
		.notify done


it "should find correct materials for upgrade", (done) !->
	matSet =
		\id : 7201

	edSvc.loadJsonReturnValue = [ matSet ]

	upgrade =
		\id : 100
		\matSetId : 1

	item =
		\id : 500
		\matSetId : 7200


	expect svc.findUpgradeMaterialsFor item, upgrade
		.to.eventually.equal matSet
		.notify done


it "should correctly tell when materials are enough for an upgrade", (done) !->
	edSvc.loadJsonReturnValue = [
		{ \id : 1, \matId : 100, \matCost : 2 }
	]

	svc.loadAllMaterialSets!
	.then ->
		edSvc.loadJsonReturnValue = [
			{ \id : 1, \matSetId : 1 }
		]
		materials = [
			{
				\id : 100
				\amount : 3
			}
		]
		armor = {
			\upgradeId : 0
			\matSetId : 0
			\itemType : \armor
		}
		svc.are materials .enoughToUpgrade armor, 1
	.then (result) ->
		expect(result).to.be.true
		done!
	.catch done


it "should correctly deduct upgrade cost from materials", (done) !->
	materialSets = [
		{ \id : 7009, \matId : 100, \matCost : 2 }
	]
	materials = [
		{ \id : 100, \amount : 5 }
	]
	armor = {
		\upgradeId : 9
		\matSetId : 7009
		\itemType : \armor
	}
	upgrades = [{ \id : 9, \matSetId : 9 }]

	edSvc.loadJsonReturnValue = materialSets

	svc.loadAllMaterialSets!
	.then ->
		edSvc.loadJsonReturnValue = upgrades
		svc.deductFrom materials .costOfUpgrade armor, 9
	.then !->
		expect(materials.0).to.have.property \amount, 3
		done!
	.catch done
