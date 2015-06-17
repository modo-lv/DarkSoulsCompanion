global? <<< require "prelude-ls"

require './modules/guide/main.ls'
require './modules/items/main.ls'

angular.module "dsc", ["LocalStorageModule", "jqwidgets", "ui.grid", "dsc-guide", "dsc-items"]

require './program/services/storageService.ls'