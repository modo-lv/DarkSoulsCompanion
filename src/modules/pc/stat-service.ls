angular?.module "dsc" .service "statSvc" (storageSvc) -> new StatService ...
###

class StatService
	@allStats = [
		\vitality
		\attunement
		\endurance
		\strength
		\dexterity
		\resistance
		\intelligence
		\faith
		\humanity
	]

	(@_storageSvc) ->
		@data = {}


	statValueOf : (name) ~>
		@loadUserData!
		@data[name]


	forEachStat : (func, model = @data) !~>
		for statName in @@allStats
			statValue = model.{}stats[statName]
			model.stats[statName] = (func statName, statValue) ? statValue


	loadUserData : !~>
		data = (@_storageSvc.load 'pc.stats') ? {}

		model = {}
		for name in @@allStats
			model[name] = data.[name] ? 8

		return @data = model


	saveUserData : (model = @data) !~>
		@_storageSvc.save 'pc.stats', model


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