storageService <-! angular.module "dsc.services" .service 'pcService'
###

svc = {}
	..PcModel = (require './models/PcModel')
	..PcStatModel = (require './models/PcStatModel')


svc.forEachStat = (model, func) !~>
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

	return model


svc.savePcData = (model) !->
	model.validate!

	data = {} <<< model
	for key, value of model
		if key != \stats
			delete data[key]

	console.log data
	storageService.save 'PcData', data

return svc