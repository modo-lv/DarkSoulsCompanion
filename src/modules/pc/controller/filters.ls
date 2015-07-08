pcSvc <-! angular.module "dsc" .filter "toStatArray"

output = []

return (model) !->
	if output.length > 0 then return output

	pcSvc.forEachStat model, (stat, name) !->
		output.push model[name]

	return output