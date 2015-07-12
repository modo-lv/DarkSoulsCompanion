angular?.module "dsc"
	.config (localStorageServiceProvider) !->
		localStorageServiceProvider.setPrefix "DarkSoulsCompanion"
	.service "storageSvc", (localStorageService) ->
		new StorageService ...


class StorageService
	(@_localStorageSvc) ->
		@profileName = ''
		@profileList = []


	switchTo : (profileName) !~>
		@profileName = profileName
		@write "currentProfileName", @profileName


	switchToCurrentProfile : !~>
		lastProfile = @read "currentProfileName"
		if lastProfile?
			@switchTo lastProfile
		else
			@loadProfileList!
			if @profileList.length < 1
				@addProfile "Default"
			else
				@switchTo @profileList.0


	loadProfileList : ~>
		@profileList.length = 0
		@profileList ++= (@read "profiles") ? []
		return @profileList


	saveProfileList : !~>
		@write "profiles", @profileList


	addProfile : (name, switchTo = true) !~>
		existing = @loadProfileList! |> find (== name)
		if not existing?
			@profileList.push name
			@saveProfileList!

		if switchTo
			@switchTo name



	deleteProfile : (name = @profileName) !~>
		if (@profileList.length > 1) and (@loadProfileList! |> find (==name))
			@profileList.splice (@profileList.indexOf name), 1
			@saveProfileList!
			@clearProfile name
			@switchTo @profileList[0]


	clearProfile : (name = @profileName) !~>
		keys = @_localStorageSvc.keys!
		profileKey = @profileKeyFrom '', name
		for key in keys
			if (key.indexOf profileKey) == 0
				@_localStorageSvc.remove key


	profileKeyFrom : (key, profileName = @profileName) ~>
		"profile:#{profileName}.#{key}"


	renameProfile : (oldName) ~>
		to : (newName) ~>
			pKey = @profileKeyFrom '', oldName
			allKeys = @_localStorageSvc.keys!
			startsWith = @_localStorageSvc.deriveKey pKey
			console.log allKeys
			#for key in allKeys
			#	if key.indexOf(startsWith) == 0


	/**
	 * Save data to user's profile
	 */
	save : (key, data) !~>
		@write (@profileKeyFrom key), data


	load : (key) ~>
		@read (@profileKeyFrom key)


	write : (key, data) !~>
		@_localStorageSvc.set key, data


	read : (key) ~>
		@_localStorageSvc.get key



module?.exports = StorageService