angular?.module "dsc" .service "statSvc" (storageSvc) -> new StatService ...
###

class StatService
	(@_storageSvc) ->
		@data = {}
		@PcModel = (require './models/PcModel')
		@PcStatModel = (require './models/PcStatModel')


	statValueOf : (name) ~>
		@loadUserData!
		@data.stats[name].total


	forEachStat : (func, model = @data) !~>
		for statName in @PcModel.Stats
			stat = model.{}stats[statName]
			model.{}stats[statName] = (func stat, statName) ? stat


	loadUserData : !~>
		data = @_storageSvc.load 'pc' ? {}
		model = (new @PcModel this) <<< data

		model.forEachStat (stat, name) ~>
			new @PcStatModel <<< data?.stats?[name]
				..name = name

		model.validate!

		return @data = model


	saveUserData : (model = @data) !~>
		model.validate!

		data = {} <<< model
		for key, value of model
			if key != \stats
				delete data[key]

		@_storageSvc.save 'pc', data


	statScalingFactorOf : (name) !~>
		statValue = @statValueOf name

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


module?.exports = StatService