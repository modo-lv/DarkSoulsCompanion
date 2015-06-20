global? <<< require "prelude-ls"


angular.module "dsc.services", []
require './program/services/storageService.ls'
require './program/services/dataExportService.ls'
require './program/services/itemService.ls'
require './program/services/inventoryService.ls'

require './modules/guide/main.ls'
require './modules/items/main.ls'
require './modules/inventory/main.ls'

angular.module "dsc", [
	"LocalStorageModule"
	"jqwidgets"
	"angucomplete-alt"

	"ui.grid"
	"ui.grid.edit"
	"ui.grid.cellNav"

	"dsc-guide"
	"dsc-items"
	"dsc-inventory"
]


