angular?.module "dsc" .controller "pcController" ($scope, uiGridConstants, statSvc, itemSvc, itemIndexSvc, storageSvc, inventorySvc) ->
	new PcController ...


class PcController
	(@$scope, @$uiGridConstants, @_statSvc, @_itemSvc, @_itemIndexSvc, @_storageSvc, @_inventorySvc) ->
		@setup!
		@load!
		@wireUp!


	setup : !~>
		@$scope <<< {
			userData : {
				stats : {}
				inventory : []
			}
			
			# Item that the user has selected in the auto-complete field
			selectedItem : null

			# Every armor set from the index, for auto-complete
			armorSets : []
			
			# Every item in the index, for auto-complete
			allItems : []
			
			itemTypes : [ \weapon \armor \item ]
		}

		@$scope.gridOptions = (require './config/inventory-grid-opts') @$uiGridConstants


	load : !~>
		@_itemIndexSvc.loadAllArmorSetEntries!
		.then (armorSets) !~>
			@$scope.armorSets = armorSets

		@_itemIndexSvc.loadAllBaseEntries!
		.then (entries) ~>
			@$scope.allItems = entries
			@_inventorySvc.clear!.load!
		.then (inv) !~>
			@$scope.userData.inventory = @$scope.gridOptions.data = inv

		@$scope.userData.stats = @_statSvc.loadUserData!


	wireUp : !~>
		for func in [
			\canUpgrade
			\upgrade
			\addArmorSet
			\addNewItem
			\saveUserData
		]
			@$scope.[func] = @.[func]
		
		for func in [\add \remove]
			@$scope.[func] = @_inventorySvc.[func]


	### Event handlers

	addNewItem : (selection) !~>
		@$scope.add selection.originalObject


	addArmorSet : (selection) !~>
		armorSet = selection.originalObject

		@_itemIndexSvc.findByArmorSet armorSet .then (armors) !~>
			armors |> each @$scope.add


	canUpgrade : (item) ~>
		item |> @_itemSvc.upgradeComp.canBeUpgraded


	upgrade : (invEntry) !~>
		@_itemSvc.findAnyItemByUid invEntry.uid
		.then (item) ~>
			@_itemSvc.getUpgraded item
		.then (upItem) !~>
			if not upItem? then return
			@$scope.remove invEntry
			@$scope.add upItem


	saveUserData : !~> @_statSvc.saveUserData @$scope.userData.stats


	### Utility functions


module?.exports = PcController