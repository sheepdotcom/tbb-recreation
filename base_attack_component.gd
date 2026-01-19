extends Node

# the base for all battler's attack components
# gives a base type with the functions that can be hooked onto and the parent variable
class_name BaseAttackComponent

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
