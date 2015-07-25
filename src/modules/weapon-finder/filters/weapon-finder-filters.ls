statSvc <- angular.module "dsc" .filter "statName"

(name) -> statSvc.@@statNames[name]