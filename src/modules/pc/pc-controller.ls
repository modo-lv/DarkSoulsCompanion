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
				gridState : {}
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
		@$scope.gridOptions.onRegisterApi = (gridApi) !~>
			@$scope.gridApi = gridApi


			gridApi.core.addRowHeaderColumn {
				name : 'rowHeaderCol'
				displayName : ''
				width : 100
				cellTemplate : 'GridRowHeader.html'
			}

			gridApi.core.on.filterChanged @$scope, !~>
				@_storageSvc.save "pc.grid-state", @$scope.gridApi.saveState.save!

			gridApi.core.on.rowsRendered @$scope, !~>
				# This way seems to be the only way to ensure that the state is restored
				# when switching between tabs.
				if not @$scope.gridState?
					@$scope.gridState = @_storageSvc.load 'pc.grid-state'
					@$scope.gridApi.saveState.restore @$scope, @$scope.gridState



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
			@setUpgradeableStatus!

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
		@setUpgradeableStatus!


	addArmorSet : (selection) !~>
		armorSet = selection.originalObject

		@_itemIndexSvc.findByArmorSet armorSet .then (armors) !~>
			armors |> each @$scope.add


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

	setUpgradeableStatus : !~>
		for invItem in @$scope.userData.inventory
			if invItem.canBeUpgraded? then continue

			if not (invItem |> @_itemSvc.upgradeComp.canBeUpgraded) then
				invItem.canBeUpgraded = false
				continue

			let inventoryItem = invItem
				@_itemSvc.findAnyItemByUid inventoryItem.uid
				.then (realItem) !~>
					inventoryItem.canBeUpgraded =
						@_itemSvc.upgradeComp.canBeUpgradedFurther realItem


module?.exports = PcController