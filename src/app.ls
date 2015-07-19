# Might as well include it directly, what's the point of loading it separately
global? <<< require 'prelude-ls'

angular.module "dsc", [
	# 1st party
	"ngRoute", "ngResource"

	# 3rd party
	"LocalStorageModule"
	"angucomplete-alt"
	"ui.grid", "ui.grid.autoResize", "ui.grid.saveState"
	"ngMask"
]
.filter 'percentage', ($filter) -> (input, decimals = 0) ->
	$filter('number')(input * 100, decimals) + '%'


require './app/routes'

require './app/services/storage-service'
require './app/services/external-data-service'
require './app/services/data-export-service'
require './app/services/notification-service'

require './app/main-controller'

!-> require "./modules/**/main.js", mode : \expand

for module in [\tracker \items \pc \weapon-finder \armor-calc]
	require "./modules/#{module}/main.js"

