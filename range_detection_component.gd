extends Node3D

class_name RangeDetectionComponent

@export var hitbox_component: HitboxComponent:
	set(value):
		hitbox_component = value
		assert(hitbox_component != null)
@export var range_area: Area3D:
	set(value):
		range_area = value
		assert(range_area != null)

@export var attack_range: int = 3:
	set(value):
		if value == null:
			attack_range = 0
		else:
			attack_range = max(value, 0)
		_update_range()

var _hitboxes_in_range: Array[HitboxComponent] = []

@onready var collision_shape: CollisionShape3D = null

func _ready():
	assert(hitbox_component != null)
	assert(range_area != null)
	
	range_area.area_entered.connect(_on_area_entered)
	range_area.area_exited.connect(_on_area_exited)
	
	collision_shape = range_area.get_node("CollisionShape3D")


func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		_hitboxes_in_range.append(area)


func _on_area_exited(area: Area3D) -> void:
	if area is HitboxComponent:
		_hitboxes_in_range.erase(area)


func _update_range():
	if attack_range != INF:
		if collision_shape.shape is SphereShape3D:
			collision_shape.shape.radius = attack_range


func get_closest_enemy() -> HitboxComponent:
	# (later) do some math to figure out what the closest point would be on certain shapes
	# for now we do center to center check but subtract radius as a very basic way to determine edge to edge distance
	var closest_enemy: HitboxComponent = null
	var smallest_distance := INF
	
	# find closest enemy
	for enemy in _hitboxes_in_range:
		if enemy.is_enemy == hitbox_component.is_enemy || enemy.is_untargettable:
			continue
		
		var distance = enemy.position.distance_squared_to(position)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy


# here friends and enemies are ABSOLUTE, basically include_enemies checks if other.is_enemy = true not if other.is_enemy != self.is_enemy
func run_for_hitboxes_in_range(callback: Callable, include_enemies := true, include_friends := true, include_untargettable := true):
	for hitbox in _hitboxes_in_range:
		if hitbox.is_untargettable && !include_untargettable:
			continue
		
		if ((hitbox.is_enemy && include_enemies) || (!hitbox.is_enemy && include_friends)) && (include_untargettable || !hitbox.is_untargettable):
			callback.call(hitbox)


func run_for_enemies_in_range(callback: Callable, include_untargettable := true):
	run_for_hitboxes_in_range(callback, !hitbox_component.is_enemy, hitbox_component.is_enemy, include_untargettable)


func run_for_friends_in_range(callback: Callable, include_untargettable := true):
	run_for_hitboxes_in_range(callback, hitbox_component.is_enemy, !hitbox_component.is_enemy, include_untargettable)


func is_an_enemy_in_range() -> bool:
	for enemy in _hitboxes_in_range:
		if enemy.is_enemy != hitbox_component.is_enemy && !enemy.is_untargettable:
			return true
	
	return false
