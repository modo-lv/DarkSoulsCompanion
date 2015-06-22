global? <<< require "prelude-ls"

angular.module "dsc.services", []
require './program/services/storageService'
require './program/services/dataExportService'
require './program/services/itemService'
require './program/services/inventoryService'

require './modules/guide/main'
require './modules/items/main'
require './modules/inventory/main'

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


