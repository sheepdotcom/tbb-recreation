extends Node

class_name BattlerEnums

static var basic_attack_component = preload("res://basic_attack_component.tscn")

enum ID {
	BATTLER = 1,
	TROWEL_BATTLER,
	SWORD_BATTLER,
	SLINGER_BATTLER,
	BALLER_BATTLER, # TODO: Basic_Knockback_Attack_Component i guess?
	ROCKET_BATTLER, # TODO: Basic_Area_Attack_Component i guess?
	BOMB_BATTLER, # TODO: Bomb_Attack_Component && Kamikaze_Attack_Component
	TITAN_BATTLER, # TODO: Basic_Area_Attack_Component i guess? && Telamon_Attack_Component
	# TODO: MORE BATTLERS AFTER IM DONE CODING THE NORMAL BATTLERS
}


# for like all of these GO INGAME AND LOOK AT ALMANAC CUZ WIKI SEEMS TO BE WRONG SOMETIMES (and fix wiki too)
const health_table: Array[Array] = [
	[50, 30, 70, 40, 80, 50, 80, 500],
	[50, 30, 70, 40, 60, 50, 30, 500]
]
const armor_table: Array[Array] = [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0]
]
const resistance_table: Array[Array] = [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0]
]
const damage_table: Array[Array] = [
	[10, 4, 15, 8, 30, 30, 200, 80],
	[10, 4, 30, 8, 20, 40, 150, 80]
]
# this one will need EXTENSIVE testing, seeing as Battler is actually 2.2 and Sword Battler is 1.05
# bomb/kamikaze battler has special function called exploding upon first attack so don't even bother checking, maybe (actually wait kamikaze can't explode when inflicted with cold and just attacks every second maybe hmm)
const attack_rate_table: Array[Array] = [
	# x    o    x     o    o    o    o    -
	[2.6, 3.0, 1.05, 0.5, 3.0, 4.0, 1.0, 0.0],
	# o   o    o     o    -    o    -    -
	[2.6, 4.0, 3.0, 1.0, 3.0, 8.0, 1.0, 0.0]
]
const attack_range_table: Array[Array] = [
	[3, 5, 5, 12, 15, 15, 3, 6],
	[3, 5, 7, 12, 18, 15, 3, 6]
]
const walkspeed_table: Array[Array] = [
	[4, 3, 4, 3, 3, 2, 5, 1.5],
	[4, 3, 4, 3, 3, 2, 10, 1.5]
]
# on the Builder Battler wiki page someone put under the stats section the recharge being 4 seconds lol, might fix that later
# Slinger Battler has 4 instead of 8 lol what is going on? (are people using loadout stats instead of almanac stats?) (not on Stunner Battler though lol)
# Rocket/Crocket Battlers are mismatched as well wtf???
const recharge_table: Array[Array] = [
	[5, 7, 6, 8, 10, 14, 15, 35],
	[5, 7, 6, 8, 10, 20, 25, 35]
]
const cost_table: Array[Array] = [
	[50, 100, 150, 200, 300, 500, 500, 1000],
	[50, 100, 150, 200, 300, 500, 500, 1000]
]
# might need testing for things without listed windups (only the wiki has windups)
# wiki windups seem correct so ill just use the wiki ones
const windup_table: Array[Array] = [
	# x     o   x      o    o    o    o    o
	[0.15, 0.0, 0.15, 0.1, 0.5, 0.3, 2.0, 0.6],
	# x     o    o     o    o    o    x    o
	[0.15, 0.0, 0.15, 0.1, 0.5, 0.6, 0.0, 0.6]
]
# this one will need EXTENSIVE testing just like attack_rate
# extensive here means spawn battlers in sandbox and record them, then check how many frames from seeing each other to starting windup
const pre_windup_table: Array[Array] = [
	# x     -    x    -    -    -    -    -
	[0.53, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
	# x     -    -    -    -    -    x    -
	[0.53, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
]



# TODO: some sort of function or table for getting all the base stats of all the battlers
static func create_component(id: ID, is_alt: bool) -> CoreAttackComponent:
	if id == ID.TITAN_BATTLER and is_alt:
		return null # TODO: Telamon attack component
	else:
		return basic_attack_component.instantiate()


static func get_health(id: ID, is_alt: bool) -> int:
	return health_table[int(is_alt)][id - 1]


static func get_armor(id: ID, is_alt: bool) -> int:
	return armor_table[int(is_alt)][id - 1]


static func get_resistance(id: ID, is_alt: bool) -> int:
	return resistance_table[int(is_alt)][id - 1]


static func get_damage(id: ID, is_alt: bool) -> int:
	return damage_table[int(is_alt)][id - 1]


static func get_attack_rate(id: ID, is_alt: bool) -> float:
	return attack_rate_table[int(is_alt)][id - 1]


static func get_attack_range(id: ID, is_alt: bool) -> int:
	return attack_range_table[int(is_alt)][id - 1]


static func get_walkspeed(id: ID, is_alt: bool) -> float:
	return walkspeed_table[int(is_alt)][id - 1]


static func get_recharge(id: ID, is_alt: bool) -> int:
	return recharge_table[int(is_alt)][id - 1]


static func get_cost(id: ID, is_alt: bool) -> int:
	return cost_table[int(is_alt)][id - 1]


static func get_windup(id: ID, is_alt: bool) -> float:
	return windup_table[int(is_alt)][id - 1]


static func get_pre_windup(id: ID, is_alt: bool) -> float:
	return pre_windup_table[int(is_alt)][id - 1]
