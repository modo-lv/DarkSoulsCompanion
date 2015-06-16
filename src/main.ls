angular.module "dsc", ["LocalStorageModule"]

require './program/services/storageService.ls'

angular.module "dsc"
	.controller "GuideController", require "./modules/guide/controller.ls"

