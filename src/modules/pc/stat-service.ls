storageSvc <-! angular.module "dsc" .service 'statSvc'
###

svc = {}
	..data = {}

	..PcModel = (require './models/PcModel')
	..PcStatModel = (require './models/PcStatModel')


svc.statValueOf = (name) ->
	svc.loadUserData!
	svc.data.stats[name].total


svc.forEachStat = (model = svc.data, func) !~>
	for statName in svc.PcModel.Stats
		stat = model.{}stats[statName]
		model.{}stats[statName] = (func stat, statName) ? stat


svc.loadUserData = !->
	data = storageSvc.load 'pc' ? {}
	model = (new svc.PcModel svc) <<< data

	model.forEachStat (stat, name) ->
		new svc.PcStatModel <<< data?.stats?[name]
			..name = name

	model.validate!

	svc.data = model

	return model


svc.saveUserData = (model = svc.data) !->
	model.validate!

	data = {} <<< model
	for key, value of model
		if key != \stats
			delete data[key]

	storageSvc.save 'pc', data


svc.statScalingFactorOf= (name) !->
	svc.loadUserData!
	statValue = svc.statValueOf name

	thresholds = switch name
		when \strength then fallthrough
		when \dexterity then [[10, 0.5] [10, 3.5] [20, 2.25]]
		when \intelligence then fallthrough
		when \faith then [[10, 0.5] [20, 2.25] [20, 1.5]]
		default ...

	result = 0
	for threshold in thresholds
		if statValue >= threshold.0
			result += threshold.0 * threshold.1
		else
			result += statValue * threshold.1
		statValue -= threshold.0
		if statValue < 1
			break

	result /= 100

	#console.log "#{name} scaling factor: #{result }"
	return result


return svc