_ <-! describe "item-upgrade-service"

var svc, edSvc, itemModels, upModels

beforeEach !->
	edSvc := new MockExternalDataService
	svc := new (testRequire "modules/items/item-upgrade-service") edSvc
	itemModels := testRequire 'modules/items/models/item-models'
	upModels := testRequire 'modules/items/models/item-upgrade-models'


it "should correctly calculate the base item ID from an upgraded one", !->
	baseId = svc.getBaseItemIdFrom 103012
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

	expect svc.getAllUpgrades \weapon
		.to.eventually.have.members [ upData ]
		.notify done