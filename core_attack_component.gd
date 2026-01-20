extends Node3D

# the base for all battler's attack components
# gives a base type with the functions that can be hooked onto and the parent variable
class_name CoreAttackComponent

# why battler and not like hitbox component? what about bases?
# well, non-battlers get their own custom attack stuff (since they don't follow the same pre-windup, windup, attack scheme)
@export var parent: Battler:
	set(value):
		parent = value
		assert(parent != null)

func _ready():
	assert(parent != null)


# don't think this one gonna ever be used lol
func _on_pre_windup():
	pass


# don't think this one gonna ever be used lol
func _on_windup():
	pass


# this function handles attack stuff, including damaging enemies
# because some battlers don't attack, like a lot of supports (healer, cola, slateskin, protest)
func _on_attack():
	pass


# don't think this one gonna ever be used lol
func _on_attack_finished():
	pass


# has some neat options, but still an underlying thing, some things might benefit from calling this directly to do their explosions
# but most would only need the basic explosion function (which will handle vfx)
func get_hitboxes_in_radius(origin: Vector3, radius: float, select_opposite_team := true, select_same_team := false, select_invisible := true) -> Array[HitboxComponent]:	
	var list: Array[HitboxComponent] = []
	
	# don't do work if no work to be needed done?
	if select_opposite_team == false && select_same_team == false:
		return list
	
	var select_friendlies = select_opposite_team if parent.is_enemy else select_same_team
	var select_enemies = select_same_team if parent.is_enemy else select_opposite_team
	
	var collisions := _get_collisions_in_radius(origin, radius)
	
	for collision in collisions:
		var collider = collision.get("collider")
		if collider is HitboxComponent:
			if select_invisible || !collider.is_invisible:
				if collider.is_enemy && select_enemies:
					list.append(collider)
				elif !collider.is_enemy && select_friendlies:
					list.append(collider)
	
	return list


# extremely generic, gives the raw info, not meant to be used outside of this class i guess
func _get_collisions_in_radius(origin: Vector3, radius: float) -> Array[Dictionary]:
	var space := get_world_3d().direct_space_state
	
	var shape := SphereShape3D.new()
	shape.radius = radius
	
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), origin)
	params.collision_mask = 1
	
	return space.intersect_shape(params)
