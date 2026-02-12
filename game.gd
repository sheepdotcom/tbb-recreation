extends Node

class_name Game

@export var parent: Node3D:
	set(value):
		assert(value != null)
		parent = value

@export var stage_select_container: Container:
	set(value):
		assert(value != null)
		stage_select_container = value

@export var unit_container: Node2D:
	set(value):
		assert(value != null)
		unit_container = value

@export var chapter := GameEnums.Chapter.BrickBattle
@export var stage := 1:
	set(value):
		stage = max(value, 1)

# save what stage you are on in each chapter so game feel better idk?
var saved_stages: Dictionary[GameEnums.Chapter, int] = {}

var in_stage := false

var battler_scene = preload("res://battler.tscn")

func _ready() -> void:
	assert(parent != null)
	assert(stage_select_container != null)
	assert(unit_container != null)
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	for v in GameEnums.Chapter.values():
		# auto add every chapter with a saved stage of 1, except if the export vars are set to some value use that for that specific chapter
		saved_stages[v] = stage if v == chapter else 1
	
	add_unit_buttons()


# dynamically do it i guess idk how fully but whatever
func fill_stage_select_container():
	# TODO: figure out what the best way to store EVERY SINGLE STAGE (name, magnification, enemy cycle oh no)
	for i in range(30):
		var button = BaseButton.new()
		button.custom_minimum_size = Vector2(100, 100)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# TODO: Add a texture or something
		var rect = ColorRect.new()
		rect.size = Vector2(100, 100)
		rect.color = Color(1, 1, 1, 1) if i%2==0 else Color(0, 0, 0, 1)
		
		button.add_child(rect)
		stage_select_container.add_child(button)


func add_unit_buttons():
	var button_size = Vector2(150, 50)
	var button_spacing = Vector2(20, 20)
	var container_half_height = 100
	
	for i in range(8):
		var button = BaseButton.new()
		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		button.position.x = ((button_size.x + button_spacing.x) * ((i % 4) - 2)) - (button_spacing.x / 2)
		@warning_ignore("integer_division") # stupid you need this ugh
		button.position.y = -container_half_height + ((((i / 4) * 2) - 1) * (button_size.y + (button_spacing.y / 2)))
		
		var rect = ColorRect.new()
		rect.size = button_size
		rect.color = Color.AQUA
		
		button.add_child(rect)
		unit_container.add_child(button)


func spawn_unit(id: BattlerEnums.ID, is_enemy: bool):
	var battler: Battler = battler_scene.instantiate()
	
	battler.is_enemy = is_enemy
	battler.id = id
	
	parent.add_child(battler)


func _on_viewport_size_changed():
	var visible_rect = get_viewport().get_visible_rect()
	
	unit_container.position.x = visible_rect.size.x / 2
	unit_container.position.y = visible_rect.size.y
