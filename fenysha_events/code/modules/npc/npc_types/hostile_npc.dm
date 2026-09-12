/mob/living/basic/npc/raider
	faction = list(FACTION_HOSTILE, FACTION_BANDIT)
	make_random_name = TRUE
	join_text = "You are a raider. Defend the zone you are in and attack outsiders. Try to keep them alive while doing so."
	important_text = "Do not attack the train, and do not pursue players! Do not remove players from the round entirely!"

	possible_outfits = list(
		/datum/outfit/trainstation_raider,
		/datum/outfit/trainstation_raider/alt,
		/datum/outfit/trainstation_raider/alt_2,
	)

	health = 200
	maxHealth = 200
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	ai_controller = /datum/ai_controller/basic_controller/npc_bandit

	ranged = TRUE
	item_r_hand = /obj/item/gun/ballistic/automatic/m90
	projectilesound = 'sound/items/weapons/gun/smg/shot_alt.ogg'
	casingtype = /obj/item/ammo_casing/c35sol
	ranged_cooldown = 3 SECONDS
	burst_shots = 3

	ghost_controlable = FALSE
	speech_phrases = list(
		NPC_TALK_KEY_IDLE = list(
			"Чё-то тихо сегодня.",
			"Сенька, наливай.",
			"Кто хабар принёс?",
			"Вот бы сейчас кого-нибудь обчистить.",
			"Зона зоной, а пожрать пора.",
			"Чё стоим?",
			"Фраера всё нет.",
			"Скоро кто-нибудь нарисуется.",
			"Не люблю я эту тишину.",
			"Похоже, сегодня без приключений."
		),
		NPC_TALK_KEY_TARGET = list(
			"Эй, фраер! А ну стой!",
			"Убери волыну, брателло.",
			"Куда прёшь?",
			"Чё припёрся?",
			"Иди сюда, поговорим.",
			"Руки от ствола убрал.",
			"Не дёргайся, мужик.",
			"Ну чё, будем базарить?",
			"Хабар выкладывай.",
			"Ты куда это собрался?",
			"Стоять, не мельтеши.",
			"Эй, браток, не спеши."
		),
		NPC_TALK_KEY_INJURED = list(
			"Ай, маслину поймал!",
			"Сука, зацепило!",
			"Вот же ж гад!",
			"По мне попали!",
			"Чёрт, больно же!",
			"Меня подбили!",
			"Пацаны, прикройте!",
			"Я ранен!",
			"Сука, кровью истекаю!",
			"Мне прилетело!"
		),
		NPC_TALK_KEY_LOWHEALTH = list(
			"Пацаны, выручайте!",
			"Мне хана, мужики!",
			"Я долго не протяну!",
			"Медика сюда, живо!",
			"Всё, походу приехали.",
			"Братва, помогите!",
			"Я кровью истекаю!",
			"Не бросайте меня!",
			"Держусь из последних сил!",
			"Да чтоб вас, совсем плохо!"
		),
		NPC_TALK_KEY_ENEMY_NEARBY = list(
			"Слышь, кто там?",
			"К нам кто-то идёт.",
			"Чужой.",
			"Вижу фраера.",
			"Приготовились.",
			"Стволы наготове.",
			"Глянь туда.",
			"Кто это там шляется?",
			"Гости пожаловали.",
			"Ща базар будет."
		),
		NPC_TALK_KEY_ENEMY_CROWD_NEARBY = list(
			"Их там целая кодла!",
			"Пацаны, их прорва!",
			"Слишком много их.",
			"Валим отсюда!",
			"Нас сейчас размажут!",
			"Целая толпа прёт!",
			"Не вывезем мы столько.",
			"Приготовьтесь, сейчас жарко будет!",
			"Отходим, живо!",
			"Ё-моё, их там до хрена!"
		),
		NPC_TALK_KEY_IN_DANGER = list(
			"Живее, живее!",
			"Ложись!",
			"Вали их!",
			"Не стой, стреляй!",
			"Мочи гадов!",
			"Прикрой меня!",
			"Справа!",
			"Сзади, сука!",
			"Дави их!",
			"Не дай им подойти!",
			"Херачь их, пацаны!",
			"Не ссы, я прикрою!",
			"Пали по ним!",
			"Отходи, мать твою!"
		)
	)


/mob/living/basic/npc/raider/meele

	melee_damage_lower = 30
	melee_damage_upper = 30
	ranged = FALSE
	item_r_hand = /obj/item/knife/combat
	item_l_hand = /obj/item/shield/riot
