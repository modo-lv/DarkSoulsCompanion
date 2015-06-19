global? <<< require "prelude-ls"


angular.module "dsc.services", []
require './program/services/storageService.ls'
require './program/services/dataExportService.ls'

require './modules/guide/main.ls'
require './modules/items/main.ls'

angular.module "dsc", [
	"LocalStorageModule"
	"jqwidgets"

	"ui.grid"
	"ui.grid.edit"
	"ui.grid.cellNav"

	"dsc-guide"
	"dsc-items"
]


