extends StaticBody3D

class_name Base

@export var is_enemy := false:
	set(value):
		is_enemy = value
		if hitbox != null:
			_update_is_enemy()

var hitbox: HitboxComponent


func _ready():
	hitbox = $HitboxComponent
	
	assert(hitbox != null)
	
	_update_is_enemy()


func _update_is_enemy():
	hitbox.is_enemy = is_enemy
