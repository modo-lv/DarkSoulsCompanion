global? <<< require "prelude-ls"

angular.module "dsc.services", []
require './program/services/storageService'
require './program/services/dataExportService'
require './program/services/itemService/main'
require './program/services/inventoryService'
require './program/services/pcService/main'

require './modules/guide/main'
require './modules/items/main'
require './modules/inventory/main'
require './modules/pc/main'

angular.module "dsc", [
	"LocalStorageModule"
	"jqwidgets"
	"angucomplete-alt"

	"ui.grid"
	"ui.grid.autoResize"

	"dsc-pc"
	"dsc-guide"
	"dsc-items"
	"dsc-inventory"
]


