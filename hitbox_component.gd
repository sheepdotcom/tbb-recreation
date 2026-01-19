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

var collision_shape: CollisionShape3D

func _ready():
	assert(parent != null)
	assert(health_component != null)
	
	collision_shape = $CollisionShape3D
	assert(collision_shape != null)


func get_radius() -> float:
	if collision_shape.shape is CapsuleShape3D:
		return collision_shape.shape.radius
	elif collision_shape.shape is SphereShape3D:
		return collision_shape.shape.radius
	elif collision_shape.shape is BoxShape3D:
		return collision_shape.shape.size.x / 2
	else:
		return 0.5 # the default value for when a shape isn't configured i guess?
