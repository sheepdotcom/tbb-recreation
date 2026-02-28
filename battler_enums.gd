extends Node

class_name BattlerEnums

# TODO: REWRITE HOW IS_ALT WORKS, MAKE ALT FORMS NOT A BOOL FLAG BUT INSTEAD A UNIQUE TYPE OF BATTLER
enum ID {
	BATTLER = 1,
	BLONDE_BATTLER,
	TROWEL_BATTLER, # TODO: Trowel_Component
	WALL, # TODO: Wall_Component
	BUILDER_BATTLER, # TODO: Builder_Component
	BIG_WALL, # TODO: Big_Wall_Component
	SWORD_BATTLER,
	BRIGAND_BATTLER,
	SLINGER_BATTLER, # TODO: Basic_Projectile_Component i guess?
	STUNNER_BATTLER, # TODO: Basic_Stun_Component i guess?
	BALLER_BATTLER, # TODO: Basic_Knockback_Component i guess?
	SOCCER_BATTLER,
	ROCKET_BATTLER, # TODO: Basic_Area_Projectile_Component i guess?
	CROCKET_BATTLER,
	BOMB_BATTLER, # TODO: Bomb_Component
	KAMIKAZE_BATTLER, # TODO: Kamikaze_Component
	TITAN_BATTLER, # TODO: Basic_Area_Attack_Component i guess?
	TELAMON_BATTLER, # TODO: Telamon_Component
	# TODO: MORE BATTLERS AFTER IM DONE CODING THE NORMAL BATTLERS
}

# dictionary for all stats, better to use for myself (instead of trying to remember battler ids as indicies)
# x attack rate, (pre-)windup tested, o not tested but inferred, - not tested
# put in the order of attack rate, windup, pre-windup
# for like all of these GO INGAME AND LOOK AT ALMANAC CUZ WIKI SEEMS TO BE WRONG SOMETIMES (and fix wiki too)
static var stat_table: Dictionary[ID, BattlerStats] = {
	#ID.BATTLER: BattlerStats.new(50, 0, 0, 10, 2.5, 3, 4.0, 5, 50, 0.15, 0.5, BasicAttackComponent, "Battler"), # x x x
	#ID.BLONDE_BATTLER: BattlerStats.new(50, 0, 0, 10, 2.5, 3, 4.0, 5, 50, 0.15, 0.5, BasicAttackComponent, "Blonde Battler"), # x x x
	#ID.TROWEL_BATTLER: BattlerStats.new(30, 0, 0, 4, 3.75, 5, 3.0, 7, 100, 0.0, 0.0, TrowelBattlerComponent, "Trowel Battler"), # x x x
	#ID.WALL: BattlerStats.new(90, 0, 0, 0, 0.0, 0, 0.0, 0, 0, 0.0, 0.0, TrowelWallComponent, "Builder Battler"), # Wall I
	#ID.BUILDER_BATTLER: BattlerStats.new(30, 0, 0, 4, 3.8, 5, 3, 7, 100, 0.0, 0.0), # x x x
	#ID.BIG_WALL: BattlerStats.new(180, 0, 0, 0, 0.0, 0.0, 0.0, 0, 0, 0.0, 0.0), # Wall II
	#ID.SWORD_BATTLER: BattlerStats.new(70, 0, 0, 15, 1.03, 5, 4, 6, 150, 0.15, 0.05), # x x x # 1.033 -> 1.03
	#ID.BRIGAND_BATTLER: BattlerStats.new(70, 0, 0, 30, 3.8, 7, 4, 6, 150, 0.15, 0.5), # x x x
	#ID.SLINGER_BATTLER: BattlerStats.new(40, 0, 0, 8, 0.525, 12, 3, 8, 200, 0.1, 0.05), # x x x
	#ID.STUNNER_BATTLER: BattlerStats.new(40, 0, 0, 8, 1.03, 12, 3, 8, 200, 0.1, 0.03), # x x x # 1.033 -> 1.03; 0.033 -> 0.03
	#ID.BALLER_BATTLER: BattlerStats.new(80, 0, 0, 30, 3.0, 15, 3, 10, 300, 0.5, 0.0), # o o -
	#ID.SOCCER_BATTLER: BattlerStats.new(60, 0, 0, 20, 3.0, 18, 3, 10, 300, 0.5, 0.0), # - o -
	#ID.ROCKET_BATTLER: BattlerStats.new(50, 0, 0, 30, 4.0, 15, 2, 14, 500, 0.3, 0.0), # o o -
	#ID.CROCKET_BATTLER: BattlerStats.new(50, 0, 0, 40, 8.0, 15, 2, 20, 500, 0.6, 0.0), # o o -
	#ID.BOMB_BATTLER: BattlerStats.new(80, 0, 0, 200, 1.0, 3, 5, 15, 500, 2.0, 0.0), # o o -
	#ID.KAMIKAZE_BATTLER: BattlerStats.new(30, 0, 0, 150, 1.0, 3, 10, 25, 500, 0.0, 0.0), # o o o
	#ID.TITAN_BATTLER: BattlerStats.new(500, 0, 0, 80, 0.0, 6, 1.5, 35, 1000, 0.6, 0.0), # - o -
	#ID.TELAMON_BATTLER: BattlerStats.new(500, 0, 0, 80, 0.0, 6, 1.5, 35, 1000, 0.6, 0.0), # - o -
}


static func create_component(id: ID) -> CoreBattlerComponent:
	var component = stat_table[id].component.new()
	
	if component is CoreBattlerComponent:
		return component
	else:
		return null


static func get_displayable_name(id: ID) -> StringName:
	return stat_table[id].name


static func get_model_name(id: ID) -> String:
	return ID.find_key(id).to_lower()


static func get_health(id: ID) -> int:
	return stat_table[id].health


static func get_armor(id: ID) -> int:
	return stat_table[id].armor


static func get_resistance(id: ID) -> int:
	return stat_table[id].resistance


static func get_damage(id: ID) -> int:
	return stat_table[id].damage


static func get_attack_rate(id: ID) -> float:
	return stat_table[id].attack_rate


static func get_attack_range(id: ID) -> int:
	return stat_table[id].attack_range


static func get_walkspeed(id: ID) -> float:
	return stat_table[id].walkspeed


static func get_recharge(id: ID) -> int:
	return stat_table[id].recharge


static func get_cost(id: ID) -> int:
	return stat_table[id].cost


static func get_windup(id: ID) -> float:
	return stat_table[id].windup


static func get_pre_windup(id: ID) -> float:
	return stat_table[id].pre_windup


static func get_abilities(id: ID) -> int:
	return stat_table[id].abilities


static func fill_the_table(reload := false):
	if !reload && !stat_table.is_empty():
		return
	
	stat_table = {}
	
	for id in ID.keys():
		var info = _load_battler_info(id.to_lower())
		
		if info == null:
			continue
		
		stat_table[ID[id]] = info


static func _load_battler_info(file_name: String) -> BattlerStats:
	var info: BattlerStats = load("res://info/units/" + file_name + ".tres")
	
	return info


# NOTE: also update the editor hints in battler_stats.gd when updating this
# note for adding things to this list: only abilities from the wiki that are PERMANENT, invincibility and i-frames are examples of TEMPORARY ones
enum Abilities {
	RED = 1 << 0, # anger explosion
	BLACK = 1 << 1, # deathmark
	ANGEL = 1 << 2, # revival
	ZOMBIE = 1 << 3, # probably not being used
	DEVIL = 1 << 4, # definitely not being used (we don't even know what it'll do)
	STARRED = 1 << 5, # definitely not being used (we don't even know what it'll do)
	ANTI_RED = 1 << 6,
	ANTI_BLACK = 1 << 7,
	ANTI_ANGEL = 1 << 8,
	ANTI_ZOMBIE = 1 << 9,
	ANTI_DEVIL = 1 << 10,
	ANTI_STARRED = 1 << 11,
	BASE_DESTROYER = 1 << 12, # 3x damage to bases
	KNOCKBACK_IMMUNITY = 1 << 13,
	TRIP_IMMUNITY = 1 << 14,
	ANNOY_IMMUNITY = 1 << 15,
	FEAR_IMMUNITY = 1 << 16, # part of "miniboss immunity"
	BLIND_IMMUNITY = 1 << 17, # part of "miniboss immunity"
	SLOW_IMMUNITY = 1 << 18, # part of "final boss immunity"
	COLD_IMMUNITY = 1 << 19, # part of "final boss immunity"
	FIRE_IMMUNITY = 1 << 20,
	HELLFIRE_IMMUNITY = 1 << 21,
	IMMOVABLE = 1 << 22,
	OMNI_IMMUNITY = 1 << 23,
	TUMORED = 1 << 24,
}
