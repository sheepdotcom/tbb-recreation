extends Node3D

# the base for all battler's components
# gives a base type with the functions that can be hooked onto and the parent variable
class_name CoreBattlerComponent

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


# run functions when taking damage i guess (called by the function that handles actually dealing damage)
func _on_damage():
	pass


# runs on death, though its not for units with a death attack (that will be handled as a phase)
func _on_death():
	pass


# runs when spawned in, handles positioning self (defaults to spawning at base)
func _on_spawn(is_enemy: bool):
	var base := parent.game.enemy_base if is_enemy else parent.game.friendly_base
	
	var pos := base.spawn_point.global_position
	pos.y += parent.hitbox.get_height() / 2
	parent.global_position = pos


# moved from Battler to this so components can override the physics update (mainly for those who do absolutely nothing, like walls)
# because of this there is a lot of referencing the parent
func physics_update(delta: float):
	# for movement later do something with vectors and also handle walkspeed (de)buffs
	# (later) basically assume left is the direction we want to go and apply stuff
	# (later) then apply is_enemy onto it so enemies go right
	# (later) this is to handle things like fear or whatever else (when implemented)
	if parent.range_detector.is_an_enemy_in_range() || parent.attacking_state >= parent.AttackingState.WINDUP:
		# i think i just realized why enemies sort of, slide, for a few frames after seeing an enemy
		# im gonna copy that too, for accuracy, and too fix a bug with the range detection
		
		# start the pre-windup
		if parent.attacking_state == parent.AttackingState.NONE:
			parent.start_pre_windup()
		
		# what an old comment that is below me, no clue what he was saying, no clue what i am either lol, though this function is not in the same place as it used to be
		# the rest is handled by timer and prewindup also by _physics_process
	else:
		# cancel prewindup if enemy exits range
		if parent.attacking_state == parent.AttackingState.PRE_WINDUP:
			parent.attacking_state = parent.AttackingState.NONE
			parent.attack_timer.stop()
		
		parent.velocity.x = parent.walkspeed

		if !parent.hitbox.is_enemy:
			parent.velocity.x = -parent.velocity.x

		# currently just rotate the battler to face direction of movement
		# (later) rotate towards target enemy when attacking
		# (later) about above: rotate towards where enemy last way until battler is done attacking or whatever (when they can start moving/attack again)
		if parent.velocity != Vector3.ZERO:
			parent.pivot.basis = Basis.looking_at(parent.velocity)

	if !parent.is_on_floor():
		parent.saved_gravity += parent.gravity * delta
		parent.velocity.y -= parent.saved_gravity


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
