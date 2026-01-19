extends Node3D

class_name HealthComponent

@export var parent: Node3D:
	set(value):
		parent = value
		assert(parent != null)

@export var max_health: int = 50
@export var armor: int = 0
@export var resistance: int = 0

@export var health_visible: bool = true

var health: int = max_health:
	set(value):
		health = clampi(value, 0, max_health)
		update_health_bar()

var health_bar: ProgressBar = null
var health_label: Label = null

var scene = preload("res://health_bar.tscn").instantiate()

func _ready():
	assert(parent != null)
	
	# preload scene, instantiate it, add it as a child, then reparent all its children to self, then delete the container they were in
	# lets just call this a hack
	add_child(scene)
	for child in scene.get_children():
		child.reparent(self)
		#add_child(child)
		
	scene.free()
	
	health_bar = $SubViewport/ProgressBar
	health_label = health_bar.get_node("Label")
	
	update_health_bar()


func damage(amount: int):
	health = health - amount


func update_health_bar():
	if health_bar == null or health_label == null:
		return
	
	# reset max health because what if it changed while the battler was alive?
	# when would that happen? Archetype Battler, yeah, that guy, im planning that far ahead ok
	# or could just be a custom sandbox feature whatever
	# yeah i plan on sandbox being WAY WAY more packed than even the teased rework
	health_bar.max_value = max_health
	health_bar.value = health
	
	health_label.text = "{0}/{1}".format([health, max_health])
	
	health_bar.visible = health_visible
