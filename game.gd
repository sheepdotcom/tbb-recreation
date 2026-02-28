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

@export var camera: Camera3D:
	set(value):
		assert(value != null)
		camera = value

@export var friendly_base: Base:
	set(value):
		assert(value != null)
		friendly_base = value

@export var enemy_base: Base:
	set(value):
		assert(value != null)
		enemy_base = value

@export var stage_select_menu: CanvasLayer:
	set(value):
		assert(value != null)
		stage_select_menu = value

@export var stage_select_container: Container:
	set(value):
		assert(value != null)
		stage_select_container = value

@export var in_game_menu: CanvasLayer:
	set(value):
		assert(value != null)
		in_game_menu = value

@export var unit_container: Control:
	set(value):
		assert(value != null)
		unit_container = value

@export var current_chapter := GameEnums.Chapter.BRICK_BATTLE
@export var current_stage := 1: # a stage of 1 here is equal to stage 1, 
	set(value):
		current_stage = max(value, 1)

@export var camera_speed := 16.0

var original_camera_position: Vector3

# Array of StageInfo, won't let me nested type ugh, basically loaded stage info
static var stages: Dictionary[GameEnums.Chapter, Array] = {}

# save what stage you are on in each chapter so game feel better idk?
var saved_stages: Dictionary[GameEnums.Chapter, int] = {}

var in_stage := false
var stage_spawn_timer: Timer
var enemy_cycle_position := 0

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
	stage_spawn_timer = $StageSpawnTimer
	
	assert(parent != null)
	assert(camera != null)
	assert(friendly_base != null)
	assert(enemy_base != null)
	assert(stage_select_menu != null)
	assert(stage_select_container != null)
	assert(in_game_menu != null)
	assert(unit_container != null)
	assert(stage_spawn_timer != null)
	
	original_camera_position = camera.position
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	for v in GameEnums.Chapter.values():
		# auto add every chapter with a saved stage of 1, except if the export vars are set to some value use that for that specific chapter
		saved_stages[v] = current_stage if v == current_chapter else 1
	
	# TODO: store info someone and retrieve later idk im not doing file storage yet
	for v in BattlerEnums.ID.values():
		saved_battler_levels[v] = 1
	
	BattlerEnums.fill_the_table()
	load_chapter_stage_info(GameEnums.Chapter.BRICK_BATTLE)
	
	add_unit_buttons()
	in_game_menu.hide()
	
	fill_stage_select_container()
	
	set_selected_stage(1)


func _process(delta: float):
	if in_stage:
		var direction = Vector3.ZERO
		
		var speed_mult := 1.0
		
		if Input.is_action_pressed("move_left"):
			direction.x -= 1.0
		if Input.is_action_pressed("move_right"):
			direction.x += 1.0
		
		if Input.is_action_pressed("camera_speed_up"):
			speed_mult *= 2.0
		if Input.is_action_pressed("camera_speed_down"):
			speed_mult *= 0.5
		
		# probably not needed but whatever who knows what if more than just moving along the x-axis?
		if direction != Vector3.ZERO:
			direction = direction.normalized()
		
		camera.position += direction * camera_speed * speed_mult * delta


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


func get_current_stage_info() -> StageInfo:
	if !stages.has(current_chapter):
		return null
	
	var chapter := stages[current_chapter]
	
	var stage = chapter.get(current_stage - 1)
	
	return stage


func start_stage():
	stage_select_menu.hide()
	in_game_menu.show()
	
	in_stage = true
	
	enemy_cycle_position = 0
	
	var stage: StageInfo = get_current_stage_info()
	
	if stage == null:
		push_error("stage is null")
		return
	
	var the_thing: EnemyCycleStorer = stage.enemy_cycle.get(enemy_cycle_position)
	
	if the_thing == null:
		push_error("enemy cycle at index %d is null" % enemy_cycle_position)
		return
	
	stage_spawn_timer.start(the_thing.time_till_spawn)


func exit_stage():
	stage_select_menu.show()
	in_game_menu.hide()
	
	in_stage = false
	
	camera.position = original_camera_position


func _on_stage_spawn_timer_timeout():
	var stage: StageInfo = get_current_stage_info()
	
	if stage == null:
		push_error("stage is null")
		return
	
	var the_thing: EnemyCycleStorer = stage.enemy_cycle.get(enemy_cycle_position)
	
	if the_thing == null:
		push_error("enemy cycle at index %d is null" % enemy_cycle_position)
		return
	
	# TODO: if check for if playing on tumore difficulty
	# TODO: account for other magnifications
	spawn_unit(the_thing.battler, true, stage.magnification)
	
	enemy_cycle_position += 1
	
	var another_thing: EnemyCycleStorer = stage.enemy_cycle.get(enemy_cycle_position)
	
	if another_thing == null:
		enemy_cycle_position = 0
		another_thing = stage.enemy_cycle.get(enemy_cycle_position)
	
	stage_spawn_timer.start(another_thing.time_till_spawn)


## stage values here MUST start at 1, zero is not valid
## if stage info fails to load, returns null, yeah YOU gotta handle it
func get_stage_info_from_file(chapter: GameEnums.Chapter, stage: int) -> StageInfo:
	var chapter_name: String = GameEnums.Chapter.find_key(chapter)
	
	var stage_info: StageInfo = load("res://info/stages/" + chapter_name.to_lower() + ("/%02d.tres" % stage))
	
	return stage_info


## loads all of the stage info of that chapter into the static variable i have
## does not load again if that stuff is already in the static variable unless reload is true
func load_chapter_stage_info(chapter: GameEnums.Chapter, reload := false):
	if !reload && stages.has(chapter):
		return
	
	var the_array: Array[StageInfo] = []
	
	for i in range(1, 31):
		var stage_info = get_stage_info_from_file(chapter, i)
		
		if stage_info == null:
			break
		
		the_array.append(stage_info)
	
	stages[chapter] = the_array


# dynamically do it i guess idk how fully but whatever
func fill_stage_select_container():
	# 215 on 16:9, 288 on 21.5:9 (basically wider screen proportionally scaled it up; 288 is roughly 215 * 21.5/16)
	var button_size = Vector2(215, 100)
	
	# TODO: loop through the stages of a chapter instead of this, do when StageInfo stores data for what map to use, map colors, and stage thumbnail
	for i in range(1, 31):
		var panel_container := PanelContainer.new()
		
		var border_style := StyleBoxFlat.new()
		
		border_style.draw_center = false
		border_style.set_border_width_all(2)
		border_style.set_corner_radius_all(2)
		border_style.corner_detail = 1
		border_style.border_color = Color(0.0, 0.318, 0.545, 1.0)
		
		panel_container.add_theme_stylebox_override("panel", border_style)
		
		var button := Button.new()
		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var texture = PlaceholderTexture2D.new()
		texture.size = button_size
		
		button.button_up.connect(set_selected_stage.bind(i))
		
		panel_container.add_child(button)
		stage_select_container.add_child(panel_container)


## for stage select menu
## new_stage starts at 1, so stage 1 is internally integer 1 here
func set_selected_stage(new_stage: int):
	var button_size = Vector2(215 + 2 + 2, 100 + 2 + 2)
	
	var visible_rect := get_viewport().get_visible_rect()
	
	stage_select_container.position.x = (visible_rect.size.x / 2) - (button_size.x / 2) - ((new_stage - 1) * (button_size.x + stage_select_container.get_theme_constant("separation")))
	
	current_stage = new_stage


func add_unit_buttons():
	var button_size = Vector2(150, 50)
	var button_spacing = Vector2(20, 20)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for i in range(8):
		var button := Button.new()
		button.custom_minimum_size = button_size
		#button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		button.position.x = ((button_size.x + button_spacing.x) * ((i % 4) - 2)) + (button_spacing.x / 2) + (unit_container.size.x / 2)
		@warning_ignore("integer_division") # stupid you need this ugh
		button.position.y = (unit_container.size.y - (button_size.y * 2) - (button_spacing.y / 2)) + ((((i / 4) * 2) - 1) * ((button_size.y / 2) + (button_spacing.y / 2)))
		
		var texture = PlaceholderTexture2D.new()
		texture.size = button_size
		
		button.button_up.connect(spawn_unit_from_loadout.bind(i))
		
		unit_container.add_child(button)


func level_to_magnification(level: int) -> float:
	return 1 + ((level - 1) * 0.2)


## returns the Battler (can be null), cuz its a wrapper around spawn_unit for specifically spawning from the 8 buttons (your loadout)
func spawn_unit_from_loadout(num: int) -> Battler:
	if num < 0 || num > 7:
		return
	
	var id := loadout[num]
	
	if id in BattlerEnums.ID.values():
		var level = level_to_magnification(saved_battler_levels[id])
		return spawn_unit(id, false, level)
	else:
		return null


## returns the Battler (can be null), so you can do stuff with it after it is spawned (if needed)
func spawn_unit(id: BattlerEnums.ID, is_enemy: bool, magnification := 1.0) -> Battler:
	if !in_stage:
		return null
	
	var battler: Battler = battler_scene.instantiate()
	
	battler.is_enemy = is_enemy
	battler.id = id
	battler.magnification = magnification
	battler.game = self
	
	# adding child to scene calls _ready, ensuring battler component is ready to be used (needed for next step im so smart lol)
	parent.add_child(battler)
	
	battler.battler_component._on_spawn(is_enemy)
	
	return battler


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
