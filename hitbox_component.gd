extends Area3D

# this component is very important, as it is what is stored when referncing to anything attackable
# basically instead of storing like a generic Node3D, or saying its a Battler, just say that its a HitboxComponent, aka anything that can be attacked
class_name HitboxComponent

@export var parent: Node3D:
	set(value):
		parent = value
		assert(parent != null)

@export var health_component: HealthComponent:
	set(value):
		health_component = value
		assert(health_component != null)

@export var is_enemy = false
@export var is_invisible = false

@export_group("Collision Shape")
@export var shape: Shape3D:
	set(value):
		shape = value
		if collision_shape != null:
			_update_shape()

@export var shape_disabled := false:
	set(value):
		shape_disabled = value
		if collision_shape != null:
			_update_shape_disabled()

@export var shape_debug_color := Color(0.00, 0.60, 0.69, 0.41):
	set(value):
		shape_debug_color = value
		if collision_shape != null:
			_update_shape_debug_color()

@export var shape_debug_fill := true:
	set(value):
		shape_debug_fill = value
		if collision_shape != null:
			_update_shape_debug_fill()

var collision_shape: CollisionShape3D

func _ready():
	assert(parent != null)
	assert(health_component != null)
	
	collision_shape = $CollisionShape3D
	assert(collision_shape != null)
	
	_update_shape()
	_update_shape_disabled()
	_update_shape_debug_color()
	_update_shape_debug_fill()


func _update_shape():
	collision_shape.shape = shape


func _update_shape_disabled():
	collision_shape.disabled = shape_disabled


func _update_shape_debug_color():
	collision_shape.debug_color = shape_debug_color


func _update_shape_debug_fill():
	collision_shape.debug_fill = shape_debug_fill


# TODO: remove this because it is used only for code that will be replaced with better code later
func get_radius() -> float:
	if collision_shape.shape is CapsuleShape3D:
		return collision_shape.shape.radius
	elif collision_shape.shape is SphereShape3D:
		return collision_shape.shape.radius
	elif collision_shape.shape is BoxShape3D:
		return collision_shape.shape.size.x / 2
	else:
		return 0.5 # the default value for when a shape isn't configured i guess?
