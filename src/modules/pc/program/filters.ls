angular.module "dsc-pc" .filter "toStatArray" (pcService) !->
	output = []

	return (model) !->
		if output.length > 0 then return output

		pcService.forEachStat model, (stat, name) !->
			output.push model[name]

		return output