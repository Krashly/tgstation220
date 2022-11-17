/mob/living/simple_animal/antroborg
	name = "antropomorph cyborg"
	desc = "A cyborg with an attrative figure, who does not have the same functionality as his relatives."
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_pk.dmi'
	icon_state = "mekapeace"
	icon_living = "mekapeace"
	icon_dead = "mekapeace-wreck"
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	maxHealth = 150
	health = 150
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 0
	wander = 0
	speed = 0
	healable = 0
	gender = FEMALE
	mob_biotypes = MOB_ROBOTIC
	speech_span = SPAN_ROBOT
	dextrous = TRUE
	dextrous_hud_type = /datum/hud/dextrous/antroborg
	bubble_icon = "machine"
	faction = list("neutral","silicon","turret")
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	hud_possible = list(DIAG_STAT_HUD, DIAG_HUD, ANTAG_HUD)
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	footstep_type = FOOTSTEP_MOB_CLAW
	held_items = list(null, null)
	var/obj/item/internal_storage
	var/obj/item/default_storage = /obj/item/storage/backpack
	var/heavy_emp_damage = 40
	var/obj/item/radio/borg/radio = null
	radio = /obj/item/radio/borg
	var/list/radio_channels = list()

/mob/living/simple_animal/antroborg/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/antroborg/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD)
		holder.icon_state = "huddead2"
	else if(incapacitated())
		holder.icon_state = "hudoffline"
	else
		holder.icon_state = "hudstat"

/mob/living/simple_animal/antroborg/handle_temperature_damage()
	return

/mob/living/simple_animal/antroborg/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	if(affect_silicon)
		return ..()

/mob/living/simple_animal/antroborg/bee_friendly()
	// Why would bees pay attention to drones?
	return TRUE

/mob/living/simple_animal/antroborg/electrocute_act(shock_damage, source, siemens_coeff, flags = NONE)
	return FALSE //

/mob/living/simple_animal/antroborg/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] \a <b>[src]</b>!")

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "She has [I.get_examine_string(user)] in her [get_held_index_name(get_held_index_of_item(I))]."

	//Internal storage
	if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
		. += "She is holding [internal_storage.get_examine_string(user)] in her internal storage."

	//Damaged
	if(health != maxHealth)
		if(health > maxHealth * 0.33) //Between maxHealth and about a third of maxHealth, between 30 and 10 for normal drones
			. += span_warning("Its screws are slightly loose.")
		else //otherwise, below about 33%
			. += span_boldwarning("Its screws are very loose!")

	//Dead
	if(stat == DEAD)
		if(client)
			. += span_deadsay("A message repeatedly flashes on its display: \"REBOOT -- REQUIRED\".")
		else
			. += span_deadsay("A message repeatedly flashes on its display: \"ERROR -- OFFLINE\".")
	. += "</span>"

/mob/living/simple_animal/antroborg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Stun(70)
	to_chat(src, span_danger("<b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)..."))
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		to_chat(src, span_userdanger("HeAV% DA%^MMA+G TO I/O CIR!%UUT!"))

/mob/living/simple_animal/antroborg/death(gibbed)
	..(gibbed)
	if(internal_storage)
		dropItemToGround(internal_storage)

/mob/living/simple_animal/antroborg/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]-rest"
	else
		icon_state = "[icon_living]"
	regenerate_icons()

/datum/action/cooldown/spell/skin_change
	name = "Change the Shell"
	desc = "You can't change it twice."
	icon_icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/actions.dmi'
	button_icon_state = "meka-skin-change"
	background_icon_state = "bg_revenant"
	spell_requirements = NONE

/mob/living/simple_animal/antroborg/general/for_spawn/proc/skin_changing()
	var/static/list/antroborg_skins = list(
		"General" = /mob/living/simple_animal/antroborg,
		"Service" = /mob/living/simple_animal/antroborg/service,
		"Service 2" = /mob/living/simple_animal/antroborg/service_alt,
		"Janitor" = /mob/living/simple_animal/antroborg/janitor,
		"Medical" = /mob/living/simple_animal/antroborg/medical,
		"Cargo" = /mob/living/simple_animal/antroborg/cargo,
		"Miner" = /mob/living/simple_animal/antroborg/miner,
		"Engineer" = /mob/living/simple_animal/antroborg/engi
	)
	var/choice = tgui_input_list(src, "Select a shell to change", "Shell", antroborg_skins)
	if(isnull(choice) || QDELETED(src))
		return FALSE
	var/mob/living/simple_animal/antroborg/general/choice_path = antroborg_skins[choice]
	if(!ispath(choice_path))
		return FALSE

	visible_message(
		span_alertalien("[src] mechanisms rotates and changes the color!"),
		span_noticealien("You have changed the shell!"),
	)

	new choice_path(loc)
	choice_path.setDir(dir)
	if(numba && unique_name)
		choice_path.numba = numba
		choice_path.set_name()
	if(mind)
		mind.name = choice_path.real_name
		mind.transfer_to(choice_path)
	qdel(src)

/datum/action/cooldown/spell/skin_change/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/skin_change/Activate(atom/target)
	var/mob/living/simple_animal/antroborg/general/for_spawn/borgo = owner
	borgo.skin_changing()

	return TRUE

/mob/living/simple_animal/antroborg/Initialize(mapload)
	. = ..()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
		if(ispath(radio))
		radio = new radio(src)
	ADD_TRAIT(src, TRAIT_ADVANCEDTOOLUSER, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_NOFIRE_SPREAD, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_LITERATE, ROUNDSTART_TRAIT)
	access_card = new /obj/item/card/id/advanced/simple_bot(src)

	var/datum/id_trim/job/cap_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/captain]
	access_card.add_access(cap_trim.access + cap_trim.wildcard_access)

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, ITEM_SLOT_DEX_STORAGE)

	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	add_verb(src, /mob/living/proc/toggle_resting)

/mob/living/simple_animal/antroborg/general/for_spawn/Initialize(mapload)
	. = ..()
	skin_change = new
	skin_change.Grant(src)

/mob/living/simple_animal/antroborg/Login()
	. = ..()
		antroborg_name()

/mob/living/simple_animal/antroborg/proc/antroborg_name()
	var/chosen_name = sanitize_name(reject_bad_text(tgui_input_text(src, "What OwOuld you like your name to be?", "ChOwOse Your Name, pweease :3", real_name, MAX_NAME_LEN)))
	if(!chosen_name)
		to_chat(src, span_warning("Select your name, pwlease! (И передайте привет Крашлику =))"))
		antroborg_name()
		return
	to_chat(src, span_notice("Your name is now [span_name("[chosen_name]")], gOwOd name <3"))
	fully_replace_character_name(null, chosen_name)

/mob/living/simple_animal/antroborg/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(stat == DEAD)
		return FALSE
	if(health >= maxHealth)
		to_chat(user, span_warning("[src]'s screws can't get any tighter!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	to_chat(user, span_notice("You start to tighten loose screws on [src]..."))

	if(!tool.use_tool(src, user, 5 SECONDS, volume=50))
		to_chat(user, span_warning("You need to remain still to tighten [src]'s screws!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	adjustBruteLoss(-15)
	visible_message(span_notice("[user] tightens [src == user ? "[user.p_their()]" : "[src]'s"] loose screws!"), span_notice("[src == user ? "You tighten" : "[user] tightens"] your loose screws."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/simple_animal/antroborg/welder_act_secondary(mob/living/user, obj/item/tool)
	if(stat == DEAD)
		return FALSE
	if(health >= maxHealth)
		to_chat(user, span_warning("[src]'s seams cannot be welded stronger!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	to_chat(user, span_notice("You start to welding seams on [src]..."))

	if(tool.use_tool(src, user, 15 SECONDS, volume=50))
		to_chat(user, span_warning("You need to remain still too weld [src]'s seams!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	adjustBruteLoss(-60)
	visible_message(span_notice("[user] welds [src == user ? "[user.p_their()]" : "[src]'s"] seams!"), span_notice("[src == user ? "You weld" : "[user] welds"] your seams."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/simple_animal/antroborg/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used?.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage

/mob/living/simple_animal/antroborg/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return TRUE
	return FALSE


/mob/living/simple_animal/antroborg/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			if(internal_storage)
				return FALSE
			return TRUE
	..()


/mob/living/simple_animal/antroborg/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_DEX_STORAGE)
			return internal_storage
	return ..()

/mob/living/simple_animal/antroborg/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
	update_held_items()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null
	I.forceMove(src)
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			internal_storage = I
			update_inv_internal_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a Krashly in Discord!"))
			return

	I.equipped(src, slot)

/mob/living/simple_animal/drone/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/drone/getBeltSlot()
	return ITEM_SLOT_DEX_STORAGE

/datum/hud/dextrous/antroborg/New(mob/owner)
	..()
	var/atom/movable/screen/inventory/inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
// inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
	inv_box.hud = src
	static_inventory += inv_box

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

/datum/supply_pack/science/antroborg
	name = "Antropomorh Cyborg Crate"
	desc = "Come on, do some trolling."
	cost = CARGO_CRATE_VALUE * 14
	access = ACCESS_ROBOTICS
	access_view = ACCESS_ROBOTICS
	contains = list(/mob/living/simple_animal/antroborg)
	crate_name = "antropomorph cyborg crate"
	crate_type = /obj/structure/closet/crate/secure/science


/mob/living/simple_animal/antroborg/service
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_serv.dmi'
	icon_state = "mekaserve"
	icon_living = "mekaserve"
	icon_dead = "mekaserve-wreck"
	default_storage = /obj/item/storage/backpack
	radio_channels = list(RADIO_CHANNEL_SERVICE)

/mob/living/simple_animal/antroborg/service_alt
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_serv.dmi'
	icon_state = "mekaserve_alt"
	icon_living = "mekaserve_alt"
	icon_dead = "mekaserve_alt-wreck"
	default_storage = /obj/item/storage/backpack
	radio_channels = list(RADIO_CHANNEL_SERVICE)

/mob/living/simple_animal/antroborg/general
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_pk.dmi'
	icon_state = "mekapeace"
	icon_living = "mekapeace"
	icon_dead = "mekapeace-wreck"
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/general/for_spawn
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_pk.dmi'
	icon_state = "mekapeace"
	icon_living = "mekapeace"
	icon_dead = "mekapeace-wreck"
	default_storage = /obj/item/storage/backpack
	var/datum/action/cooldown/spell/skin_change/skin_change

/mob/living/simple_animal/antroborg/janitor
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_jani.dmi'
	icon_state = "mekajani"
	icon_living = "mekajani"
	icon_dead = "mekajani-wreck"
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/medical
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_med.dmi'
	icon_state = "mekamed"
	icon_living = "mekamed"
	icon_dead = "mekamed-wreck"
	radio_channels = list(RADIO_CHANNEL_MEDICAL)
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/cargo
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_cargo.dmi'
	icon_state = "mekacargo"
	icon_living = "mekacargo"
	icon_dead = "mekacargo-wreck"
	radio_channels = list(RADIO_CHANNEL_SUPPLY)
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/miner
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_mine.dmi'
	icon_state = "mekamine"
	icon_living = "mekamine"
	icon_dead = "mekamine-wreck"
	radio_channels = list(RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SCIENCE)
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/engi
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_eng.dmi'
	icon_state = "mekaengi"
	icon_living = "mekaengi"
	icon_dead = "mekaengi-wreck"
	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	default_storage = /obj/item/storage/backpack

///////////////////////EMAGed//////////////////////////////
/mob/living/simple_animal/antroborg/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/mob/living/simple_animal/antroborg/ninja/new_borg
	if(src.stat == DEAD)
		return
	new new_borg(loc)
	new_borg.setDir(dir)
	if(numba && unique_name)
		new_borg.numba = numba
		new_borg.set_name()
	if(mind)
		mind.name = new_borg.real_name
		mind.transfer_to(new_borg)
	qdel(src)

/mob/living/simple_animal/antroborg/emag_act(mob/user, obj/item/card/emag/emag_card)
	var/mob/living/simple_animal/antroborg/syndicat/new_borg
	if(src.stat == DEAD)
		return
	new new_borg(loc)
	new_borg.setDir(dir)
	if(numba && unique_name)
		new_borg.numba = numba
		new_borg.set_name()
	if(mind)
		mind.name = new_borg.real_name
		mind.transfer_to(new_borg)
	qdel(src)

/mob/living/simple_animal/antroborg/syndicat
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_syndi.dmi'
	icon_state = "mekasyndi"
	icon_living = "mekasyndi"
	icon_dead = "mekasyndi-wreck"
	radio = /obj/item/radio/borg/syndicate
	radio_channels = list(RADIO_CHANNEL_SYNDICATE)
	default_storage = /obj/item/storage/backpack

/mob/living/simple_animal/antroborg/ninja
	icon = 'code/modules/mob/living/carbon/antropomorph_borg/icons/tallrobot_ninja.dmi'
	icon_state = "mekaninja"
	icon_living = "mekaninja"
	icon_dead = "mekaninja-wreck"
	radio = /obj/item/radio/borg/syndicate
	radio_channels = list(RADIO_CHANNEL_SYNDICATE)
	default_storage = /obj/item/storage/backpack

