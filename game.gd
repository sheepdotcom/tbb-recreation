extends Node

# Welcome to Game! The class for all generic game stuff!
# What does it have in store for us? Well, it contains a bunch of references to phsyical objects, as seen below!
# Does it have more? Of course it does! It also contains more permanent things like the currently selected chapter, stage, and loadout!
# It handles both menu stuff and the actual game!
class_name Game

@export var parent: Node3D:
	set(value):
		assert(value != null)
		parent = value

@export var friendly_base: Base:
	set(value):
		assert(value != null)
		friendly_base = value

@export var enemy_base: Base:
	set(value):
		assert(value != null)
		enemy_base = value

@export var stage_select_container: Container:
	set(value):
		assert(value != null)
		stage_select_container = value

@export var unit_container: Control:
	set(value):
		assert(value != null)
		unit_container = value

@export var chapter := GameEnums.Chapter.BRICK_BATTLE
@export var stage := 1:
	set(value):
		stage = max(value, 1)

# save what stage you are on in each chapter so game feel better idk?
var saved_stages: Dictionary[GameEnums.Chapter, int] = {}

var in_stage := true

var unit_count := 0

# base upgrade levels [Base Health, Cannon Power, Unit Limit, Unit Recharge, Bank Income, Early Economy, Bank Capacity, Enemy Bounty]
var saved_base_levels: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]

var saved_battler_levels: Dictionary[BattlerEnums.ID, int] = {}

var loadout: Array[int] = [
	BattlerEnums.ID.BATTLER,
	BattlerEnums.ID.TROWEL_BATTLER,
	0,
	0,
	0,
	0,
	0,
	0,
]

var current_bank := GameEnums.Bank.DEFAULT
var current_cannon := GameEnums.Cannon.DEFAULT

var bank_level := 1

var battler_scene = preload("res://battler.tscn")

func _ready() -> void:
	assert(parent != null)
	assert(stage_select_container != null)
	assert(unit_container != null)
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	for v in GameEnums.Chapter.values():
		# auto add every chapter with a saved stage of 1, except if the export vars are set to some value use that for that specific chapter
		saved_stages[v] = stage if v == chapter else 1
	
	# TODO: store info someone and retrieve later idk im not doing file storage yet
	for v in BattlerEnums.ID.values():
		saved_battler_levels[v] = 1
	
	add_unit_buttons()


func _physics_process(_delta: float):
	# awesome, isnt it? yeah no its not
	if Input.is_action_just_pressed("spawn_unit_1"):
		spawn_unit_from_loadout(0)
	if Input.is_action_just_pressed("spawn_unit_2"):
		spawn_unit_from_loadout(1)
	if Input.is_action_just_pressed("spawn_unit_3"):
		spawn_unit_from_loadout(2)
	if Input.is_action_just_pressed("spawn_unit_4"):
		spawn_unit_from_loadout(3)
	if Input.is_action_just_pressed("spawn_unit_5"):
		spawn_unit_from_loadout(4)
	if Input.is_action_just_pressed("spawn_unit_6"):
		spawn_unit_from_loadout(5)
	if Input.is_action_just_pressed("spawn_unit_7"):
		spawn_unit_from_loadout(6)
	if Input.is_action_just_pressed("spawn_unit_8"):
		spawn_unit_from_loadout(7)


# dynamically do it i guess idk how fully but whatever
func fill_stage_select_container():
	# TODO: figure out what the best way to store EVERY SINGLE STAGE (name, magnification, enemy cycle oh no)
	for i in range(30):
		var button := BaseButton.new()
		button.custom_minimum_size = Vector2(100, 100)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# TODO: Add a texture or something
		var rect := ColorRect.new()
		rect.size = Vector2(100, 100)
		rect.color = Color(1, 1, 1, 1) if i%2==0 else Color(0, 0, 0, 1)
		
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		button.add_child(rect)
		stage_select_container.add_child(button)


func add_unit_buttons():
	var button_size = Vector2(150, 50)
	var button_spacing = Vector2(20, 20)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for i in range(8):
		var button := BaseButton.new()
		button.custom_minimum_size = button_size
		#button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		button.position.x = ((button_size.x + button_spacing.x) * ((i % 4) - 2)) + (button_spacing.x / 2) + (unit_container.size.x / 2)
		@warning_ignore("integer_division") # stupid you need this ugh
		button.position.y = (unit_container.size.y - (button_size.y * 2) - (button_spacing.y / 2)) + ((((i / 4) * 2) - 1) * ((button_size.y / 2) + (button_spacing.y / 2)))
		
		var rect := ColorRect.new()
		rect.size = button_size
		rect.color = Color.AQUA
		
		# insane, no, crazy, or crazy+, whatever, idk wanted to say something fe2 related or something? (44 day streak as of writing this)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		button.button_up.connect(spawn_unit_from_loadout.bind(i))
		
		button.add_child(rect)
		unit_container.add_child(button)


func level_to_magnification(level: int) -> float:
	return 1 + ((level - 1) * 0.2)


func spawn_unit_from_loadout(num: int):
	if num < 0 || num > 7:
		return
	
	var id := loadout[num]
	
	if id in BattlerEnums.ID.values():
		var level = level_to_magnification(saved_battler_levels[id])
		spawn_unit(id, false, level)


func spawn_unit(id: BattlerEnums.ID, is_enemy: bool, magnification := 1.0):
	if !in_stage:
		return
	
	var battler: Battler = battler_scene.instantiate()
	
	battler.is_enemy = is_enemy
	battler.id = id
	battler.magnification = magnification
	battler.game = self
	
	parent.add_child(battler)
	
	# TODO: Deployed Elsewhere should not be an ability
	if (battler.abilities & BattlerEnums.Abilities.DEPLOYED_ELSEWHERE) == 0:
		var base := enemy_base if is_enemy else friendly_base
		
		var pos := base.spawn_point.global_position
		pos.y += battler.hitbox.get_height() / 2
		battler.global_position = pos


func get_friendly_base_health() -> int:
	# normally base hp is 750, but because of slammer doing 33.33% increase (strange number) and the existance of liberty, I do something else
	# use the smallest numbers (would be 500 and 250 respectively for those numbers)
	var base_hp := 2 + (saved_base_levels[0] * 1)
	
	# doing it this way so idk why but whatever, probably to match up with the function below (cannon damage)
	if current_cannon == GameEnums.Cannon.SLAMMER:
		base_hp *= 500
	elif current_cannon == GameEnums.Cannon.LIBERTY:
		base_hp *= 250
	else:
		base_hp *= 375
	
	return base_hp


# NOTE: stats show in float, but ingame the damage value is ceilinged i guess (recoil is the only one with this issue though)
func get_cannon_damage() -> float:
	# might be easier to do this with tiny numbers
	var base_damage := 2.0 + (saved_base_levels[1] * 1.0)
	
	if current_cannon == GameEnums.Cannon.DEFAULT:
		base_damage *= 25.0
	elif current_cannon == GameEnums.Cannon.GATLING:
		base_damage *= 4.0
	elif current_cannon == GameEnums.Cannon.SLAMMER:
		base_damage *= 125.0
	elif current_cannon == GameEnums.Cannon.RECOIL:
		# what is wrong with recoil, why can it display DECIMALS? (i think it rounds, .5 rounds up in this game, or they just ceil for everything)
		base_damage *= 2.5
	elif current_cannon == GameEnums.Cannon.TREASURE:
		base_damage *= 75.0
	else:
		# absorber and liberty both have 0 damage
		base_damage = 0.0
	
	return base_damage


func get_unit_limit() -> int:
	return 10 + saved_base_levels[2]


func get_unit_recharge_percent() -> float:
	if current_bank == GameEnums.Bank.POWERHOUSE:
		# estimate on the powerhouse recharge thing idk (roughly 0.022222 yeah its a repeating decimal)
		return 0.75 + (saved_base_levels[3] * 2.0 / 90.0)
	else:
		return 1.0 + (saved_base_levels[3] * 0.05)


# NOTE: in-stage bank level upgrades actually decrease the time between ticks, meaning higher bank level is faster ticking, interesting
# NOTE: stats display with up to 1 decimal, though it actually increments by the full amount, also ingame cash display is rounded to an integer but seems to internally hold a float
func get_income_per_tick() -> float:
	if current_bank == GameEnums.Bank.INVESTMENT:
		return 0.8 + (saved_base_levels[4] * 0.4)
	elif current_bank == GameEnums.Bank.POWERHOUSE:
		return 1.2 + (saved_base_levels[4] * 0.78)
	else:
		return 1.0 + (saved_base_levels[4] * 0.5)


# level 1, 10 ticks per second
# level 2, 12 ticks per second
# level 3, 12 ticks per second
# level 4, 15 ticks per second
# level 5, 16 ticks per second
# level 6, 20 ticks per second
# level 7, 30 ticks per second
# level 8, 30 ticks per second
# level 9+, 60 ticks per second
# TODO: i cant figure out how tf ignition works, like its slightly less, but i cant figure out the right number (seems to be slightly above 8.8) and the wiki doesnt have it either
func get_income_tick_rate(level: int) -> int:
	if level <= 1:
		return 10
	elif level <= 3:
		return 12
	elif level <= 4:
		return 15
	elif level <= 5:
		return 16
	elif level <= 6:
		return 20
	elif level <= 8:
		return 30
	else:
		return 60


func get_starting_cash() -> int:
	return saved_base_levels[5] * 50


# NOTE: is a float, but when displayed it is rounded down (idk 62.5 rounds down to 62)
func get_bank_capacity(level: int) -> float:
	return (500.0 + (saved_base_levels[6] * 250.0)) * (1.0 + (0.125 * (level - 1)))


func get_enemy_bounty_percent() -> float:
	if current_bank == GameEnums.Bank.INVESTMENT || current_bank == GameEnums.Bank.IGNITION:
		return saved_base_levels[7] * 0.1
	elif current_bank == GameEnums.Bank.DETONATOR:
		return 2.0 + (saved_base_levels[7] * 0.25)
	elif current_bank == GameEnums.Bank.BLOOD_ALTAR:
		return 0.0
	else:
		return saved_base_levels[7] * 0.15


func _on_viewport_size_changed():
	var visible_rect := get_viewport().get_visible_rect()
	
	unit_container.position.x = visible_rect.size.x / 2
	unit_container.position.y = visible_rect.size.y
