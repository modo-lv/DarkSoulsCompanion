$scope, pcService <-! angular.module "dsc-pc" .controller "PcController"
###

$scope.model = pcService.loadPcData!

$scope.saveStats = !-> pcService.savePcData $scope.model