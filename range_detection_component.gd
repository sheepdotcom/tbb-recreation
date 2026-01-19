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

var enemies_in_range: Array[HitboxComponent] = []
var closest_enemy: HitboxComponent = null

@onready var collision_shape: CollisionShape3D = null

func _ready():
	assert(hitbox_component != null)
	assert(range_area != null)
	
	range_area.area_entered.connect(_on_area_entered)
	range_area.area_exited.connect(_on_area_exited)
	
	collision_shape = range_area.get_node("CollisionShape3D")


func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		if area.is_enemy != hitbox_component.is_enemy:
			enemies_in_range.append(area)


func _on_area_exited(area: Area3D) -> void:
	if area is HitboxComponent:
		if area.is_enemy != hitbox_component.is_enemy:
			enemies_in_range.erase(area)


func _update_range():
	if attack_range != INF:
		if collision_shape.shape is SphereShape3D:
			collision_shape.shape.radius = attack_range
