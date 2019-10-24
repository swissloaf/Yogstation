// Crew has to build a minimum of 2 structures, the first being the Energy Bridge, and the second being the Crystal Laser
// Energy Bridge is essentially just a bluespace crystal on a pedestal, which beams energy to CC, in exchange for money
// Crystal Laser is essentially just a powersink, except it shoots all the energy it has into the Energy Bridge instead of exploding
// The only way to power the Energy Bridge is through the lasers

/datum/station_goal/ebridge
	name = "Energy Bridge"
	var/sentEnergy = 0 // In MegaJoules
	var/requiredEnergy = 0 // In GigaJoules

/datum/station_goal/ebridge/New()
	.=..()
	requiredEnergy = rand(1, 10) // Numbers pulled out of thin air, probably needs to be balanced later

/datum/station_goal/ebridge/get_report()
	return {"We have recently entered into a contract with [pick(GLOB.companies)].
	 We need you to construct an Energy Bridge and export at least [requiredEnergy] GigaJoules.

	 Base parts are available for shipping via cargo.
	 -Nanotrasen Sales Department"}

/datum/station_goal/ebridge/on_report()
	//Unlock Energy Bridge
	var/datum/supply_pack/engineering/ebridge/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/ebridge]
	var/datum/supply_pack/engineering/claser/Q = SSshuttle.supply_packs[/datum/supply_pack/engineering/claser]
	P.special_enabled = TRUE
	Q.special_enabled = TRUE

/datum/station_goal/ebridge/check_completion()
	if(..())
		return TRUE
	if((sentEnergy/1000) > requiredEnergy)
		return TRUE
	return FALSE

/obj/item/powersink/claser
	name = "Crystal Laser"
	desc = "Used for powering an Energy Bridge."
	admins_warned = TRUE //Don't bother messaging the admins to tell that we're gonna go off, since it'll (probably) be fine

/obj/item/powersink/claser/charged()
	var/obj/machinery/ebridge/E =  locate(/obj/machinery/ebridge, get_step(get_step(src, dir), dir)) //get an ebridge 2 tiles away
	if(!E)
		message_admins("Crystal Laser at ([x],[y],[z] - <A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is full, and there is no connecting energy bridge. Explosion imminent.")
		explosion(loc, 2, 4, 8, 16) //Half as strong as a normal powersink's explosion
		return 
	
