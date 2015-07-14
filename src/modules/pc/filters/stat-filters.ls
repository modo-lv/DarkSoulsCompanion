# Filter to create a proper-order array from a stats object

statSvc <-! angular.module "dsc" .filter "toStatArray"

output = []

return (model) !->
	if output.length > 0 then return output

	statSvc.forEachStat ((name, value) !->
		output.push {"name" : name, "value" : value}
	), model

	return output