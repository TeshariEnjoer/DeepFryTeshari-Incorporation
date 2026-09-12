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

	var/trader_tier = TRAID_TIER_NOOB

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
