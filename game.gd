extends Node

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

@export var chapter := GameEnums.Chapter.BrickBattle
@export var stage := 1:
	set(value):
		stage = max(value, 1)

# save what stage you are on in each chapter so game feel better idk?
var saved_stages: Dictionary[GameEnums.Chapter, int] = {}

var in_stage := true

var saved_battler_levels: Dictionary[BattlerEnums.ID, int] = {}

var loadout: Array[int] = [
	BattlerEnums.ID.BATTLER,
	BattlerEnums.ID.TROWEL_BATTLER,
	BattlerEnums.ID.SWORD_BATTLER,
	0,
	0,
	0,
	0,
	0,
]

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
		
		button.add_child(rect)
		stage_select_container.add_child(button)


func add_unit_buttons():
	var button_size = Vector2(150, 50)
	var button_spacing = Vector2(20, 20)
	var container_half_height = 100
	
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
	
	parent.add_child(battler)
	
	# TODO: Deployed Elsewhere should not be an ability
	if (battler.abilities & BattlerEnums.Abilities.DEPLOYED_ELSEWHERE) == 0:
		if is_enemy:
			battler.position.x = enemy_base.position.x + 8
		else:
			battler.position.x = friendly_base.position.x - 8


func _on_viewport_size_changed():
	var visible_rect = get_viewport().get_visible_rect()
	
	unit_container.position.x = visible_rect.size.x / 2
	unit_container.position.y = visible_rect.size.y
