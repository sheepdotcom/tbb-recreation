extends CoreBattlerComponent

class_name BasicAttackComponent

func _on_attack():
	var closest_enemy := parent.get_closest_enemy()
	
	if closest_enemy == null:
		return
	
	var enemy_health := closest_enemy.health_component
	
	enemy_health.damage(parent.get_actual_damage(), parent.hitbox)
