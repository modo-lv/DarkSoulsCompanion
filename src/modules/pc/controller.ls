$scope, pcService <-! angular.module "dsc" .controller "PcController"
###

$scope.model = pcService.loadUserData!

$scope.saveStats = !-> pcService.saveUserData $scope.model