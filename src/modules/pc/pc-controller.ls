$scope, pcSvc <-! angular.module "dsc" .controller "pcController"
###

$scope.model = pcSvc.loadUserData!

$scope.saveStats = !-> pcSvc.saveUserData $scope.model