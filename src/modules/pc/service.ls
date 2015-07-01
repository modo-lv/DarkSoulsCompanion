storageService <-! angular.module "dsc" .service 'pcService'
###

svc = {}
	..data = {}

	..PcModel = (require './models/PcModel')
	..PcStatModel = (require './models/PcStatModel')


svc.statValueOf = (name) -> svc.data.stats[name].total


svc.forEachStat = (model = svc.data, func) !~>
	for statName in svc.PcModel.Stats
		stat = model.{}stats[statName]
		model.{}stats[statName] = (func stat, statName) ? stat


svc.loadUserData = !->
	data = storageService.load 'pc' ? {}
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

	storageService.save 'pc', data


return svc