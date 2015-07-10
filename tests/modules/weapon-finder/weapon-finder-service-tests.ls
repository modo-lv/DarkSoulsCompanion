_ <-! describe "weapon-finder-service"

var svc

beforeEach !->
	createServiceStack!
	svc := new (testRequire 'modules/weapon-finder/weapon-finder-service') itemSvc, statSvc, $q

	weapons = [
		{ id : 100 , uid : \weapon100 , itemType : \weapon , atkPhy : 1 }
		{ id : 100 , uid : \weapon100 , itemType : \weapon , atkPhy : 1 }
		{ id : 200 , uid : \weapon200 , itemType : \weapon , atkPhy : 1 }
		{ id : 300 , uid : \weapon300 , itemType : \weapon , atkPhy : 1 }
		{ id : 400 , uid : \weapon400 , itemType : \weapon , atkPhy : 1 }
	]

	inventory = [
		{ id : 100 , uid : \weapon100 , itemType : \weapon }
		{ id : 200 , uid : \weapon100 , itemType : \weapon }
		{ id : 300 , uid : \weapon200 , itemType : \weapon }
		{ id : 400 , uid : \weapon300 , itemType : \weapon }
	]

	edSvc.loadJsonReturnValue = weapons
	storageSvc.loadReturnValue = inventory


it "should only find fitting weapons", (done) !->
	# At the moment there aren't any parameters yet,
	# so the whole weapon set is returned
	svc.findFittingWeapons!
	.then (weapons) !->
		expect weapons .to.have.length 4
		done!
	.catch done


it "should find the best weapons", (done) !->
	svc.findBestWeapons!
	.then (weapons) !->
		expect weapons .to.have.length 4
		done!
	.catch done