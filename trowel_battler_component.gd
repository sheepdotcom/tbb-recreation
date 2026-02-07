extends BasicAttackComponent

class_name TrowelBattlerComponent

var timer := Timer.new()

var has_built_wall := false

func _ready():
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout():
	has_built_wall = true


func _on_attack():
	super._on_attack()
	
	if !has_built_wall:
		timer.start(10.0)
		has_built_wall = true
