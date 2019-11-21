/obj/machinery/power/breaker
	name = "power breaker"
	icon = 'icons/obj/power.dmi'
	icon_state = "bbox_off" //bbox_on , bbox_fault
	anchored = TRUE
	density = TRUE
	var/on = FALSE
	var/last_change_time
	var/area/area

/obj/machinery/power/breaker/examine(mob/user)
	..()
	to_chat(user, "A device that controls power flow through it, useful for advanced grid control.")
	to_chat(user, "It seems to be [on ? "on" : "off"].")

/obj/machinery/power/breaker/New()
	GLOB.breakers_list += src
	last_change_time = world.time
	area = get_area(src)
	name = "[area] power breaker"

/obj/machinery/power/breaker/proc/flip_breaker(var/state)
	on = state
	if(on)
		icon_state = "bbox_on"
		var/list/connection_dirs = list()
		for(var/direction in GLOB.alldirs)
			for(var/obj/structure/cable/C in get_step(src, direction))
				if(C.d1 == turn(direction, 180) || C.d2 == turn(direction, 180))
					connection_dirs += direction
					break
		for(var/direction in connection_dirs)
			var/obj/structure/cable/C = new /obj/structure/cable(src.loc)
			C.d1 = 0
			C.d2 = direction
			C.icon_state = "[C.d1]-[C.d2]"

			var/datum/powernet/PN = new()
			PN.add_cable(C)
			C.mergeConnectedNetworks(C.d2)
			C.mergeConnectedNetworksOnTurf()
			playsound(src, 'sound/machines/terminal_on.ogg', 50, 1)
	else
		icon_state = "bbox_off"
		for(var/obj/structure/cable/C in src.loc)
			qdel(C)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, 1)
	last_change_time = world.time

/obj/machinery/power/breaker/attack_hand(mob/user)
	. = ..()
	if(world.time > last_change_time + 300)
		if(do_after(user, 300, target = src))
			flip_breaker(!on)
			to_chat(user, "<span class='notice' You toggle [src] [on ? "on" : "off"].")
	else
		to_chat(user, "<span class='notice'>[src] is still recalibrating from last change. Please wait.</span>")

/obj/machinery/power/breaker/attack_ai(mob/user)
	. = ..()
	if(world.time > last_change_time + 100) //ai can do this quicker.
		if(do_after(user, 20, target = src))
			flip_breaker(!on)
			to_chat(user, "<span class='notice' You toggle [src] [on ? "on" : "off"].")
	else
		to_chat(user, "<span class='notice'>[src] is still recalibrating from last change. Please wait.</span>")
