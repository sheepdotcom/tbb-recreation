extends BasicAttackComponent

class_name TrowelBattlerComponent

var timer := Timer.new()

var wall_on_cooldown := false

func _ready():
	add_child(timer)
	
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout():
	wall_on_cooldown = false


func _on_attack():
	super._on_attack()
	
	if !wall_on_cooldown:
		var wall := parent.game.spawn_unit(BattlerEnums.ID.WALL, parent.is_enemy, parent.magnification)
		
		# global_position is probably a stupid idea but whatever, im only setting it once
		wall.global_position = global_position + -parent.pivot.basis.z * 3.0 # where he looking, 3 studs forwards
		
		timer.start(10.0)
		wall_on_cooldown = true
