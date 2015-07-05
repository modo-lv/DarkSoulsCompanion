_ <-! describe "item-upgrade-service"

var svc, edSvc, itemSvc

beforeEach !->
	edSvc := new MockExternalDataService
	itemSvc := new (testRequire "modules/items/services/item-service") edSvc
	svc := new (testRequire "modules/items/services/item-upgrade-service") itemSvc


it "should correctly calculate the base item ID from an upgraded one", !->
	baseId = svc.getBaseItemIdFrom 103012
	expect baseId .to.equal 103000



it "should find the correct base item from upgraded one", (done) !->
	upItem =
		\id : 103012
		\name : "Some Weapon+12"
	baseItem =
		\id : 103000
		\name : "Some Weapon"

	edSvc.loadJsonReturnValue = [ upItem, baseItem ]

	expect svc.findBaseItemOf upItem
		.to.eventually.equal baseItem
		.notify done