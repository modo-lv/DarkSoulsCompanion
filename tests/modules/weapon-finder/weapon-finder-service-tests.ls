_ <-! describe "weapon-finder-service"

var svc

beforeEach !->
	createServiceStack!
	svc := new (testRequire 'modules/weapon-finder/weapon-finder-service') itemSvc, inventorySvc, statSvc, $q

	weapons = [
		{ id : 100 , uid : \weapon100 , itemType : \weapon , atkPhy : 1 , reqStr : 1 }
		{ id : 100 , uid : \weapon100 , itemType : \weapon , atkPhy : 1 , reqStr : 10 }
		{ id : 200 , uid : \weapon200 , itemType : \weapon , atkPhy : 1 , reqStr : 15 }
		{ id : 300 , uid : \weapon300 , itemType : \weapon , atkPhy : 1 , reqStr : 20 }
		{ id : 400 , uid : \weapon400 , itemType : \weapon , atkPhy : 1 , reqStr : 25 }
	]

	inventory = [
		{ id : 100 , uid : \weapon100 , itemType : \weapon }
		{ id : 200 , uid : \weapon100 , itemType : \weapon }
		{ id : 300 , uid : \weapon200 , itemType : \weapon }
		{ id : 400 , uid : \weapon300 , itemType : \weapon }
	]

	edSvc.loadJsonReturnValue = weapons
	storageSvc.loadReturnValue = inventory


it "should only find weapons within stat requirement limits", (done) !->
	svc.params.stats = [ 12 ]

	weaponList = [
		{ id : 100 , uid : \weapon100 , itemType : \weapon , req : [1] }
		{ id : 100 , uid : \weapon100 , itemType : \weapon , req : [10] }
		{ id : 200 , uid : \weapon200 , itemType : \weapon , req : [15] }
	]

	svc.findFittingWeaponsIn weaponList
	.then (weapons) !->
		expect weapons .to.exist
		expect weapons .to.have.length 2
		done!
	.catch done