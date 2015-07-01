# Might as well include it directly, what's the point of loading it separately
global? <<< require 'prelude-ls'

angular.module "dsc.common", ["LocalStorageModule"]

require './common/services/storageService'
require './common/services/dataExportService'

angular.module "dsc", [
	# 1st party
	"ngRoute", "ngResource"

	# 3rd party
	"angucomplete-alt"
	"ui.grid", "ui.grid.autoResize"

	# Mine
	"dsc.common"
]
.filter 'percentage', ($filter) -> (input, decimals = 0) ->
	$filter('number')(input * 100, decimals) + '%'

require './app/routes'


!-> require "./modules/**/main.js", mode : \expand


for module in [\guide \items \inventory \pc \w-calc]
	require "./modules/#{module }/main.js"

