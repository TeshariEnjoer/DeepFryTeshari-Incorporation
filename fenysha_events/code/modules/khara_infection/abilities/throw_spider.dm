/obj/projectile/meat_ball
	name = "Meat ball"
	icon_state = "mini_leaper"
	speed = 0.5
	range = 16
	layer = LARGE_MOB_LAYER
	can_hit_turfs = TRUE
	var/mob_type

/obj/projectile/meat_ball/on_hit(atom/target, blocked, pierce_hit)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.visible_message(span_danger("[living_target] is splattered with blood!"), span_userdanger("You're splattered with blood!"))
		living_target.add_blood_DNA(list("Non-human DNA" = random_human_blood_type()))
		living_target.Knockdown(2 SECONDS)
	for(var/turf/blood_turf in view(src, 1))
		new /obj/effect/decal/cleanable/blood(blood_turf)
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	new mob_type(get_turf(src))
	. = ..()

/obj/projectile/meat_ball/huge
	speed = 0.4

/obj/projectile/meat_ball/huge/Initialize(mapload)
	. = ..()
	var/matrix/new_transform = matrix()
	new_transform.Scale(3, 3)
	animate(src, transform = new_transform, time = 3 SECONDS)

/datum/action/cooldown/mob_cooldown/throw_spider
	name = "Throw meat spider ball"
	button_icon_state = "berserk_mode"
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE

	var/projectile_type = /obj/projectile/meat_ball/huge
	var/mob_type = /mob/living/basic/khara_mutant/flesh_spider/weaker

/datum/action/cooldown/mob_cooldown/throw_spider/Activate(atom/target)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(launch_thing), target)

/datum/action/cooldown/mob_cooldown/throw_spider/proc/launch_thing(atom/target)
	new /obj/effect/temp_visual/telegraphing/boss_hit(get_turf(target))
	sleep(1 SECONDS)

	var/obj/projectile/meat_ball/ball = new projectile_type(get_turf(owner))
	ball.mob_type = mob_type
	ball.aim_projectile(target, owner)
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 30, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	INVOKE_ASYNC(ball, TYPE_PROC_REF(/obj/projectile, fire))
