/mob/living/simple_animal/necromorph/infector
	name = "necromorph infector"
	icon = 'icons/necromorph/infector.dmi'
	icon_state = "infector"
	icon_living = "infector"
	icon_dead = "infector-lying"
	faction = ROLE_NECROMORPH
	health = 150
	maxHealth = 150
	melee_damage_lower = 15
	melee_damage_upper = 15
	pressure_resistance = 200
	sharpness = 1
	pixel_x = -8
	base_pixel_x = -8
	footstep_type = FOOTSTEP_MOB_SHOE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	var/datum/action/cooldown/spell/night_vision/necromorph/night_vision
	var/datum/action/cooldown/spell/conjure/infector/infector
	var/datum/action/cooldown/spell/conjure/harvester/harvester
	var/datum/action/cooldown/spell/regress_to_slasher/regress
	var/datum/action/cooldown/spell/touch/dead_body_turning/turning

/mob/living/simple_animal/necromorph/infector/Initialize(mapload)
		. = ..()
		ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		infector = new
		harvester = new
		night_vision = new
		regress = new
		turning = new
		night_vision.Grant(src)
		regress.Grant(src)
		infector.Grant(src)
		harvester.Grant(src)
		turning.Grant(src)

/datum/action/cooldown/spell/conjure/infector
	name = "Puke up infector"
	desc = "The infector spreads corruption throughout the station."
	background_icon_state = "bg_revenant"
	icon_icon = 'icons/mob/actions/actions_necromorph.dmi'
	button_icon_state = "corruption-h"

	cooldown_time = 30 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/corruption/node)

/datum/action/cooldown/spell/conjure/harvester
	name = "Puke up harvester"
	desc = "Harvester extracts the biomass necessary for the spread of corruption and for the ability to."
	icon_icon = 'icons/mob/actions/actions_necromorph.dmi'
	button_icon_state = "harvester"
	background_icon_state = "bg_revenant"

	cooldown_time = 120 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/corruption/node/harvester)

/datum/action/cooldown/spell/night_vision/necromorph
	name = "Strain your eyes"
	desc = "You strain your eyes to see better in the dark."
	background_icon_state = "bg_revenant"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	cooldown_time = 0 SECONDS

/datum/action/cooldown/spell/regress_to_slasher
	name = "Regress to slasher"
	desc = "Evolution! But in the opposite direction..."
	panel = "Necromorph"
	icon_icon = 'icons/mob/actions/actions_necromorph.dmi'
	button_icon_state = "slasher"
	background_icon_state = "bg_revenant"
	spell_requirements = NONE

/datum/action/cooldown/spell/touch/dead_body_turning
	name = "Turn the corpse into a Necromorph"
	desc = "You turn a human corpse into a new necromorph."
	panel = "Necromorph"
	icon_icon = 'icons/mob/actions/actions_necromorph.dmi'
	button_icon_state = "slasher_plus"
	background_icon_state = "bg_revenant"
	spell_requirements = NONE

/mob/living/simple_animal/necromorph/proc/infector_regress(var/mob/living/simple_animal/necromorph/slasher/new_necromorph)
	visible_message(
		span_alertalien("[src] begins to twist and contort!"),
		span_noticealien("You begin to evolve!"),
	)
	new_necromorph.setDir(dir)
	if(numba && unique_name)
		new_necromorph.numba = numba
		new_necromorph.set_name()
	if(mind)
		mind.name = new_necromorph.real_name
		mind.transfer_to(new_necromorph)
	qdel(src)

/datum/action/cooldown/spell/regress_to_slasher/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/regress_to_slasher/Activate(atom/target)
	var/mob/living/simple_animal/necromorph/evolver = owner
	var/mob/living/simple_animal/necromorph/slasher/new_necromorph = new(owner.loc)
	evolver.infector_regress(new_necromorph)
	return TRUE

/mob/living/simple_animal/necromorph/proc/dead_body_turningo(var/mob/living/carbon/target, var/mob/living/simple_animal/necromorph/slasher/new_necromorph)
	if(!target.death())
		return
	visible_message(span_alertalien("[src] begins to turn the body into a pile of meat."), span_noticealien("You're starting to create a new necromorph!"))
	target.apply_damage(100, BRUTE)
	target.death()
	new_necromorph.setDir(dir)
	if(target.numba && target.unique_name)
		new_necromorph.numba = target.numba
		new_necromorph.set_name()
	if(target.mind)
		target.mind.name = new_necromorph.real_name
		target.mind.transfer_to(new_necromorph)


/datum/action/cooldown/spell/touch/dead_body_turning/Activate(atom/cast_on)
	var/mob/living/carbon/target
	var/mob/living/simple_animal/necromorph/slasher/new_necromorph = new(target.loc)
	target.dead_body_turningo

/datum/action/cooldown/spell/touch/dead_body_turning/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	return TRUE

/mob/living/simple_animal/necromorph/slasher/proc/GhostSummon(gib_on_success=TRUE)
	var/mob/living/carbon/owner
	if(!owner)
		return

	var/list/candidates = poll_ghost_candidates("Do you want to play as an necromorph slasher that will burst out of [owner.real_name]?", ROLE_NECROMORPH, ROLE_NECROMORPH, 100)

	if(QDELETED(src) || QDELETED(owner))
		return

	if(!candidates.len || !owner)
		addtimer(CALLBACK(src))
		return

	var/mob/dead/observer/ghost = pick(candidates)

	var/atom/necro_loc = get_turf(owner)
	var/mob/living/simple_animal/necromorph/slasher/new_necromorph = new(necro_loc)
	new_necromorph.key = ghost.key
	SEND_SOUND(new_necromorph, sound('sound/voice/hiss5.ogg',0,0,0,100)) //To get the player's attention
	ADD_TRAIT(new_necromorph, TRAIT_IMMOBILIZED, type) //so we don't move during the bursting animation
	ADD_TRAIT(new_necromorph, TRAIT_HANDS_BLOCKED, type)
	new_necromorph.notransform = 1

	sleep(6)

	if(QDELETED(src) || QDELETED(owner))
		qdel(new_necromorph)
		CRASH("AttemptGrow failed due to the early qdeletion of source or owner.")

	if(new_necromorph)
		REMOVE_TRAIT(new_necromorph, TRAIT_IMMOBILIZED, type)
		REMOVE_TRAIT(new_necromorph, TRAIT_HANDS_BLOCKED, type)
		new_necromorph.notransform = 0
		new_necromorph.invisibility = 0

	new_necromorph.visible_message(span_danger("[new_necromorph] bursts out of [owner] in a shower of gore!"), span_userdanger("You exit [owner], your previous host."), span_hear("You hear organic matter ripping and tearing!"))
	owner.gib(TRUE)
	qdel(src)
