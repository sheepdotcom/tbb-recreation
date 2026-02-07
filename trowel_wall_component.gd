extends CoreBattlerComponent

class_name TrowelWallComponent

var timer := Timer.new()

var is_decaying := false

# TODO: wall decay i guess

func _ready():
	parent.abilities |= BattlerEnums.Abilities.OMNI_IMMUNITY
	
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)
	
	timer.start(10.0)


func _on_timer_timeout():
	is_decaying = true
	parent.health_component.damage(parent.max_health * 0.1, parent.hitbox)
	timer.start(0.2)
