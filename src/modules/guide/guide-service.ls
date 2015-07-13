$resource <-! angular .module "dsc" .service "guideSvc"

svc = {}

svc.getContentFor = (section) ->
	$resource "/modules/guide/content/#{section}.json" .query!

return svc