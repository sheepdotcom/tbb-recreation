extends CoreBattlerComponent

class_name WallComponent

var timer := Timer.new()

var is_decaying := false

func _ready():
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)
	
	timer.start(10.0)


# do nothing cuz we a wall we don't attack or move
@warning_ignore("unused_parameter")
func physics_update(delta: float):
	pass


# do nothing, cuz trowel battler is the one who positions me
@warning_ignore("unused_parameter")
func _on_spawn(is_enemy: bool):
	pass


func _on_timer_timeout():
	is_decaying = true
	parent.health_component.damage(int(parent.max_health * 0.1), parent.hitbox)
	timer.start(0.2)
