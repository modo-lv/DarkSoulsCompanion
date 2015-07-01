$resource <-! angular .module "dsc" .service "guideService"

svc = {}

svc.getContentFor = (section) ->
	$resource "/modules/guide/content/#{section}.json" .query!

return svc