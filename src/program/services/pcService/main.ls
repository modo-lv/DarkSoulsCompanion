storageService <-! angular.module "dsc.services" .service 'pcService'
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


svc.loadPcData = !->
	data = storageService.load 'PcData' ? {}
	model = (new svc.PcModel svc) <<< data

	model.forEachStat (stat, name) ->
		new svc.PcStatModel <<< data?.stats?[name]
			..name = name

	model.validate!

	svc.data = model

	return model


svc.savePcData = (model = svc.data) !->
	model.validate!

	data = {} <<< model
	for key, value of model
		if key != \stats
			delete data[key]

	storageService.save 'PcData', data


return svc