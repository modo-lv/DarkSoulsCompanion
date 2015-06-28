require! [ \fs \csv-parse ]
global <<< require \prelude-ls

raw = {}
	..names = {}
	..descs = {}
	..effects = {}
	..materialSets = {}
	..upgrades = {}

	..weapons = []

	..items = {}



pathMap =
	0 : null # Normal
	5 : \Crystal
	10 : \Lightning
	15 : \Raw
	20 : \Magic
	22 : \Enchanted
	25 : \Divine
	30 : \Occult
	35 : \Fire
	40 : \Chaos
	45 : null  # Unique (demon, dragon, boss, etc.)


effectMap =
	\bleed : 6
	\poison : 2
	\toxic : 5
	\heal : 199


parseTexts = (data) !->
	target = {}
	for row in data
		target[+row.\Id] = row.\Value
	return target


console.log "Loading names..."
nameFiles = [ \weapon_name \weapon_name_dlc ]

a = 0
for file in nameFiles
	content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
	csvParse content, { \columns : true } (err, data) !->
		if err? then throw err
		raw.{}names <<< parseTexts data
		if ++a == nameFiles.length - 1
			loadDescs!

loadDescs = !->
	a = 0
	console.log "Loading descriptions..."
	descFiles = [ \weapon_desc \weapon_desc_dlc ]
	for file in descFiles
		content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
		csvParse content, { \columns : true }, (err, data) !->
			if err? then throw err
			raw.{}descs <<< parseTexts data
			if ++a == descFiles.length - 1
				loadUpgrades!

loadUpgrades = !->
	console.log "Loading reinforcement data..."
	content = fs.readFileSync \upgrades.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}upgrades[row.\Id] = row
		loadWeapons!

loadWeapons = !->
	console.log "Loading weapon data..."
	content = fs.readFileSync \weapons.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.[]weapons.push row
		loadEffects!

loadEffects = !->
	console.log "Loading effect data..."
	content = fs.readFileSync \effects.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}effects[row.\Id] = row
		loadItems!


loadItems = !->
	console.log "Loading item data..."
	content = fs.readFileSync \items.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}items[row.\Id] = row
		loadMaterialSets!


loadMaterialSets = !->
	console.log "Loading material set data..."
	content = fs.readFileSync \materialSets.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}materialSets[row.\Id] = row
		processWeapons!


setTexts = (item) !->
	item.name = raw.names[item.id]
	item.desc = raw.descs[item.id]


applyWeaponUpgrade = (weapon, baseUpgradeId, iteration) !->
	weapon.upgradeId = baseUpgradeId + iteration

	upgrade = raw.upgrades[weapon.upgradeId]
	if not upgrade? then return false

	weapon
		..id += iteration
		.. |> setTexts

		for mapping in [
			[\dmgPhys \PhysicsAtkRate]
			[\dmgMagic \MagicAtkRate]
			[\dmgFire \FireAtkRate]
			[\dmgLight \ThunderAtkRate]
			[\dmgStam \StaminaAtkRate]

			[\scaleStr \CorrectStrengthRate]
			[\scaleDex \CorrectAgilityRate]
			[\scaleInt \CorrectMagicRate]
			[\scaleFaith \CorrectFaithRate]

			[\defPoison \PoisonGuardResistRate]
			[\defBleed \BloodGuardResistRate]
			[\defCurse \CurseGuardResistRate]
			[\stability \StaminaGuardDefRate]
		]
			weapon[mapping.0] = weapon[mapping.0] * upgrade[mapping.1] |> Math.floor

	weapon
		..defPhys *= +upgrade.\PhysicsGuardCutRate
		..defMagic *= +upgrade.\MagicGuardCutRate
		..defFire *= +upgrade.\FireGuardCutRate
		..defLight *= +upgrade.\ThunderGuardCutRate

	# Costs
	materialSet = raw.materialSets[+upgrade.\MaterialSetId]
	#console.log materialSet
	weapon
		..upgradeMaterialId = +materialSet.\MaterialId01
		..upgradeMaterialAmount = +materialSet.\ItemNum01

	return true


processWeapons = !->
	console.log "Processing weapons..."
	weapons = []
	for rawWeapon in raw.weapons
		# Skip ammo
		if [\Arrow \Bolt] |> any (== rawWeapon.\WeaponCategory)
			continue

		weapon = {}
			..id = +rawWeapon.\Id

			.. |> setTexts
			..durability = +rawWeapon.\DurabilityMax
			..weight = +rawWeapon.\Weight
			..framptValue = +rawWeapon.\SellValue
			..path = pathMap[+rawWeapon.\BaseChangeCategory]

			..weaponCategory = rawWeapon.\WeaponCategory
			..canBlock = rawWeapon.\EnableGuard == \True
			..canParry = rawWeapon.\EnableParry == \True
			..castsMagic = rawWeapon.\EnableMagic == \True
			..castsPyromancy = rawWeapon.\EnableSorcery == \True
			..castsMiracles = rawWeapon.\EnableMiracle == \True
			..canDamageGhosts = rawWeapon.\IsVersusGhostWep == \True
			..iconId = +rawWeapon.\IconId
			..hasRegularDamage = rawWeapon.\IsNormalAttackType == \True
			..hasStrikeDamage = rawWeapon.\IsBlowAttackType == \True
			..hasSlashDamage = rawWeapon.\IsSlashAttackType == \True
			..hasThrustDamage = rawWeapon.\IsThrustAttackType == \True
			..isEnchantable = rawWeapon.\IsEnhance == \True
			..reqStr = +rawWeapon.\ProperStrength
			..reqDex = +rawWeapon.\ProperAgility
			..reqInt = +rawWeapon.\ProperMagic
			..reqFaith = +rawWeapon.\ProperFaith

			# Stagger resistance?
			#..stability = rawWeapon.\GuardBaseRepel

			# Stagger attack?
			# ..stagger = rawWeapon.\AttackBaseRepel

			..dmgPhys = +rawWeapon.\AttackBasePhysics
			..dmgMagic = +rawWeapon.\AttackBaseMagic
			..dmgFire = +rawWeapon.\AttackBaseFire
			..dmgLight = +rawWeapon.\AttackBaseThunder
			..dmgStam = +rawWeapon.\AttackBaseStamina

			..scaleStr = +rawWeapon.\CorrectStrength
			..scaleDex = +rawWeapon.\CorrectAgility
			..scaleInt = +rawWeapon.\CorrectMagic
			..scaleFaith = +rawWeapon.\CorrectFaith

			..defPhys = +rawWeapon.\PhysGuardCutRate
			..defMagic = +rawWeapon.\MagGuardCutRate
			..defFire = +rawWeapon.\FireGuardCutRate
			..defLight = +rawWeapon.\ThunGuardCutRate

			..defPoison = +rawWeapon.\PoisonGuardResist
			..defBleed = +rawWeapon.\BloodGuardResist
			..defCurse = +rawWeapon.\CurseGuardResist

			..stability = +rawWeapon.\StaminaGuardDef

			..divineMod = +rawWeapon.\AntSaintDamageRate * 100 |> Math.floor
			..occultMod = +rawWeapon.\AntWeakA_DamageRate * 100 |> Math.floor

			..upgradeSouls = +rawWeapon.\BasicPrice
			..upgradeMaterialId = 0
			..upgradeMaterialAmount = 0

			..path = pathMap[+rawWeapon.\BaseChangeCategory]

			..shotRange = +rawWeapon.\BowDistRate

		# Bleed & poison
		for effectField in [\SpEffectBehaviorId0 \SpEffectBehaviorId1 \SpEffectBehaviorId2 ]
			continue unless +rawWeapon[effectField] > 0

			effect = raw.effects[+rawWeapon[effectField]]

			switch +effect.\StateInfo
			| effectMap.\bleed => weapon
				..bleedBuildup = +effect.\RegistBlood
				..bleedDamage = +effect.\ChangeHpRate
			| effectMap.\toxic => fallthrough
			| effectMap.\poison => weapon
				..poisonBuildup = +effect.\PoizonAttackPower
				..poisonDps = +effect.\ChangeHpPoint
			| effectMap.\heal => weapon
				..healPerHit = -1 * effect.\ChangeHpPoint

		#if (not weapon.name?) or weapon.name.indexOf(\Dagger) < 0 then continue

		applyWeaponUpgrade weapon, +rawWeapon.\ReinforceTypeId , 0
		weapons.push weapon

		# Generate actual versions
		/*
		for a from 0 to 15
			newWeapon = {} <<< weapon
			if applyWeaponUpgrade newWeapon, +rawWeapon.\ReinforceTypeId, a
				weapons.push newWeapon
		*/





	fs.writeFileSync 'weapons.json', JSON.stringify weapons