#define TRAID_TIER_NOOB "low_tier"
#define TRAID_TIER_PRO "medium_tier"
#define TRAID_TIER_COOK "high_tier"

#define TRAID_AMMO_PRICE_RATIO 0.15

#define WEAPON_TRAIDER_TRAIDS list( \
    TRAID_TIER_NOOB = list( \
        /obj/item/gun/ballistic/automatic/pistol/sol = 100, \
        /obj/item/gun/ballistic/automatic/pistol/trappiste = 90, \
        /obj/item/gun/ballistic/automatic/pistol/m1911 = 180, \
        /obj/item/gun/ballistic/automatic/pistol/plasma_marksman = 150, \
        /obj/item/gun/ballistic/automatic/pistol/sec_glock = 80, \
        /obj/item/gun/ballistic/revolver/takbok = 120, \
        /obj/item/gun/ballistic/rifle/sks = 300, \
        /obj/item/gun/ballistic/shotgun/lethal = 250, \
        /obj/item/gun/ballistic/automatic/sniper_rifle/modular/blackmarket = 1200, \
        /obj/item/gun/ballistic/automatic/battle_rifle = 800, \
        /obj/item/gun/ballistic/automatic/m6pdw = 350, \
        /obj/item/ammo_box/advanced/s12gauge/buckshot = 35, \
        /obj/item/ammo_box/advanced/s12gauge/dragonsbreath = 60, \
        /obj/item/ammo_box/advanced/s12gauge/rubber = 20, \
        /obj/item/ammo_box/c10mm/ap = 35, \
        /obj/item/ammo_box/c10mm/fire = 45, \
        /obj/item/ammo_box/c10mm/hp = 50, \
        /obj/item/ammo_box/c35sol = 30, \
        /obj/item/ammo_box/c35sol/incapacitator = 40, \
        /obj/item/ammo_box/c40sol = 35, \
        /obj/item/ammo_box/c40sol/fragmentation = 45, \
        /obj/item/ammo_box/c9mm/ap = 25, \
        /obj/item/knife/hunting = 50, \
        /obj/item/melee/tomahawk = 60, \
    ), \
    TRAID_TIER_PRO = list( \
        /obj/item/gun/ballistic/automatic/pistol/sol = 100, \
    ), \
    TRAID_TIER_COOK = list( \
        /obj/item/gun/ballistic/automatic/pistol/sol = 100, \
    ), \
)

#define FOOD_TRAIDER_TRAIDS list( \
    TRAID_TIER_NOOB = list( \
        /obj/item/food/baked_cheese = 15, \
        /obj/item/food/beef_wellington = 5, \
        /obj/item/food/bowled/amanitajelly = 7, \
        /obj/item/food/bread/banana = 10, \
        /obj/item/food/bread/sausage = 8, \
        /obj/item/food/burger/big_blue = 12, \
        /obj/item/food/burger/superbite = 15, \
        /obj/item/food/cake/berry_chocolate_cake = 30, \
        /obj/item/food/cake/berry_vanilla_cake = 30, \
        /obj/item/food/cake/brioche = 30, \
        /obj/item/food/cake/clown_cake = 30, \
        /obj/item/food/cake/fruit = 30, \
        /obj/item/food/cake/pavlova = 25, \
        /obj/item/food/cake/wedding = 50, \
        /obj/item/food/bubblegum = 1, \
        /obj/item/food/bubblegum/happiness = 3, \
        /obj/item/food/bubblegum/nicotine = 2, \
        /obj/item/food/bonbon/chocolate_truffle = 5, \
        /obj/item/food/bonbon/peanut_truffle = 5, \
        /obj/item/reagent_containers/condiment/milk = 7, \
        /obj/item/reagent_containers/condiment/moth_milk = 5, \
        /obj/item/food/grown/carrotlike/carrot = 1, \
        /obj/item/food/grown/citrus/orange = 1, \
        /obj/item/food/grown/melonlike/watermelon = 5, \
		/obj/item/food/grown/pineapple = 5, \
		/obj/item/food/grown/pumpkin = 8, \
		/obj/item/food/grown/tomato = 2, \
		/obj/item/food/grown/banana/bunch = 5, \
		/obj/item/food/grown/apple = 2, \
		/obj/item/food/grown = 1, \
    ), \
    TRAID_TIER_PRO = list( \
        /obj/item/food/baked_cheese = 15, \
    ), \
    TRAID_TIER_COOK = list( \
        /obj/item/food/baked_cheese = 15, \
    ), \
)

#define MEDICAL_TRAIDER_TRAIDS list( \
    TRAID_TIER_NOOB = list( \
        /obj/item/clothing/mask/surgical = 2, \
        /obj/item/stack/medical/mesh/advanced = 10, \
        /obj/item/stack/medical/suture/medicated = 15, \
        /obj/item/stack/medical/wound_recovery = 10, \
        /obj/item/stack/medical/wound_recovery/rapid_coagulant = 8, \
        /obj/item/stack/medical/wrap/gauze = 5, \
        /obj/item/stack/medical/wrap/gauze/sterilized = 15, \
        /obj/item/stack/medical/ointment = 5, \
        /obj/item/storage/medkit/combat_surgeon/stocked = 150, \
        /obj/item/storage/medkit/civil_defense/stocked = 75, \
        /obj/item/storage/backpack/duffelbag/deforest_medkit/stocked = 170, \
        /obj/item/storage/medkit/robotic_repair/preemo/stocked = 90, \
        /obj/item/storage/medkit/frontier/stocked = 80, \
        /obj/item/storage/medkit/brute = 120, \
        /obj/item/storage/medkit/fire = 100, \
        /obj/item/storage/medkit/toxin = 8, \
        /obj/item/storage/medkit/tactical/premium = 700, \
        /obj/item/storage/pouch/medical = 60, \
        /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun = 60, \
        /obj/item/storage/box/syringes/variety = 35, \
        /obj/item/storage/pill_bottle/epinephrine = 90, \
        /obj/item/storage/pill_bottle/mannitol = 150, \
        /obj/item/storage/pill_bottle/painkiller = 150, \
        /obj/item/storage/pill_bottle/prescription_stimulant = 350, \
		/obj/item/storage/pill_bottle/stimulant = 550, \
		/obj/item/reagent_containers/hypospray/medipen/stimulants = 1200, \
    ), \
    TRAID_TIER_PRO = list( \
        /obj/item/food/baked_cheese = 15, \
    ), \
    TRAID_TIER_COOK = list( \
        /obj/item/food/baked_cheese = 15, \
    ), \
)


/mob/living/basic/npc/trader/weapons
	name = "Weapon Traider"
	health = 1500
	maxHealth = 1500
	faction = list(FACTION_CIVILIAN, FACTION_TRADER, FACTION_NEUTRAL)

	melee_damage_lower = 30
	melee_damage_upper = 30
	melee_damage_type = BRUTE

	ranged = TRUE
	item_r_hand = /obj/item/gun/ballistic/automatic/tommygun
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	casingtype = /obj/item/ammo_casing/c45
	ragned_shots_before_reload = 50

	burst_shots = 3

	ai_controller = /datum/ai_controller/basic_controller/npc_traider

	possible_outfits = list(
		/datum/outfit/trader/weapons,
	)

	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/knockdown_target = BB_BASIC_MOB_ABILITY_KNOCKDOWN,
	)

	trader_tier = TRAID_TIER_NOOB
	trader_dialogue = list(
		"Looking for something to protect yourself with?",
		"Everything here is tested. Mostly.",
		"Need a gun? Ammo? Something bigger?",
		"Don't point that at me unless you intend to buy it.",
		"Good weapons aren't cheap. Neither is staying alive.",
		"I've got what you need. If you can afford it.",
		"Take your time. Just don't touch anything you aren't buying.",
	)

/mob/living/basic/npc/trader/weapons/InitializeTrade()
	var/list/trades_by_tier = WEAPON_TRAIDER_TRAIDS
	var/list/current_trades = trades_by_tier[trader_tier]

	if(!current_trades)
		return

	var/variation

	switch(trader_tier)
		if(TRAID_TIER_NOOB)
			variation = 0.20

		if(TRAID_TIER_PRO)
			variation = 0.30

		if(TRAID_TIER_COOK)
			variation = 0.40

		else
			variation = 0

	for(var/item_type in current_trades)
		var/base_price = current_trades[item_type]

		var/price = round(
			rand(
				base_price * (1 - variation),
				base_price * (1 + variation),
			)
		)

		trades += list(
			NPC_TRADE(
				item_type,
				1,
				price,
				rand(5, 20),
				TRADER_OFFER_SELL,
			)
		)

		/*
		 * Automatically add ammunition for weapons.
		 */
		if(ispath(item_type, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/weapon = new item_type(null)
			var/atom/ammo_type = weapon.accepted_magazine_type

			qdel(weapon)

			if(ammo_type)
				var/ammo_price = max(
					1,
					round(base_price * TRAID_AMMO_PRICE_RATIO),
				)

				ammo_price = round(
					rand(
						ammo_price * (1 - variation),
						ammo_price * (1 + variation),
					)
				)

				trades += list(
					NPC_TRADE(
						ammo_type,
						1,
						ammo_price,
						rand(10, 35),
						TRADER_OFFER_SELL
					)
				)


/mob/living/basic/npc/trader/food
	name = "Food trader"
	health = 250
	health = 250
	faction = list(FACTION_CIVILIAN, FACTION_TRADER, FACTION_NEUTRAL)

	ai_controller = /datum/ai_controller/basic_controller/piecefull
	possible_outfits = list(
		/datum/outfit/trader/food,
	)

	trader_tier = TRAID_TIER_NOOB
	trader_dialogue = list(
		"Looking for something to eat?",
		"Fresh food. Well... fresh enough.",
		"Don't worry, everything here is perfectly edible.",
		"Got something to trade for a decent meal?",
		"Food keeps people alive. That's good business.",
		"I've got something for every taste.",
		"Take a look. You might find something you miss.",
	)

/mob/living/basic/npc/trader/food/InitializeTrade()
	var/list/trades_by_tier = FOOD_TRAIDER_TRAIDS
	var/list/current_trades = trades_by_tier[trader_tier]

	if(!current_trades)
		return

	var/variation

	switch(trader_tier)
		if(TRAID_TIER_NOOB)
			variation = 0.20

		if(TRAID_TIER_PRO)
			variation = 0.30

		if(TRAID_TIER_COOK)
			variation = 0.40

		else
			variation = 0

	for(var/item_type in current_trades)
		var/base_price = current_trades[item_type]

		var/price = round(
			rand(
				base_price * (1 - variation),
				base_price * (1 + variation),
			)
		)

		trades += list(
			NPC_TRADE(
				item_type,
				1,
				price,
				rand(5, 40),
				TRADER_OFFER_SELL,
			)
		)


/mob/living/basic/npc/trader/medical
	name = "Medical trader"
	health = 250
	health = 250
	faction = list(FACTION_CIVILIAN, FACTION_TRADER, FACTION_NEUTRAL)

	ai_controller = /datum/ai_controller/basic_controller/piecefull
	possible_outfits = list(
		/datum/outfit/trader/medical,
	)

	trader_tier = TRAID_TIER_NOOB
	trader_dialogue = list(
		"Need medical supplies?",
		"Bandages, medicine, stimulants. Whatever keeps you breathing.",
		"Better to buy medicine before you need it.",
		"Try not to get yourself killed. It makes my job easier.",
		"I have supplies for most common injuries.",
		"Medical equipment isn't cheap, but neither is dying.",
		"Take a look. Everything here has a purpose.",
	)


/mob/living/basic/npc/trader/medical/InitializeTrade()
	var/list/trades_by_tier = MEDICAL_TRAIDER_TRAIDS
	var/list/current_trades = trades_by_tier[trader_tier]

	if(!current_trades)
		return

	var/variation

	switch(trader_tier)
		if(TRAID_TIER_NOOB)
			variation = 0.20

		if(TRAID_TIER_PRO)
			variation = 0.30

		if(TRAID_TIER_COOK)
			variation = 0.40

		else
			variation = 0

	for(var/item_type in current_trades)
		var/base_price = current_trades[item_type]

		var/price = round(
			rand(
				base_price * (1 - variation),
				base_price * (1 + variation),
			)
		)

		trades += list(
			NPC_TRADE(
				item_type,
				1,
				price,
				rand(5, 20),
				TRADER_OFFER_SELL,
			)
		)


/mob/living/basic/npc/trader/medical/tesh
	species = /datum/species/teshari
	add_hair = FALSE

	possible_outfits = list(
		/datum/outfit/trader/medical_teshari,
	)

	trader_dialogue = list(
		"Need something for the road?",
		"Medicine, bandages, stimulants... I've got a little of everything.",
		"Try to stay in one piece, okay?",
		"Don't wait until you're bleeding to buy supplies.",
		"You're looking a little worse for wear.",
		"Everything here is useful. Eventually.",
		"Take a look. I won't bite.",
	)
