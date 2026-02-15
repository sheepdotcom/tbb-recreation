extends Node3D

class_name HealthComponent

@export var parent: Node3D:
	set(value):
		parent = value
		assert(parent != null)

@export var max_health: int = 50
@export var armor: int = 0
@export var resistance: int = 0

@export var health_visible: bool = true

var health: int = max_health:
	set(value):
		health = clampi(value, 0, max_health)
		update_health_bar()

var health_bar: ProgressBar = null
var health_label: Label = null

func _ready():
	assert(parent != null)
	
	health_bar = $SubViewport/ProgressBar
	health_label = health_bar.get_node("Label")
	
	update_health_bar()


# damage this thing or whatever, reason for damager is so we can get attributes that would multiply damage or do other stuff
# attributes like armor/resistance piercing and or damage multiplying, anti-*, red units <50% hp, 3x damage to omni-immunity
# TODO: figure out how tf to code and detect libery cannon activation
# TODO: figure out how to do the highlighting when damaged thing and the custom highlight colors for armor and resistance
func damage(amount: int, attacker: HitboxComponent):
	var amt: float = amount # i love being terrible at naming variables
	
	if attacker.parent is Battler:
		var other = attacker.parent as Battler
		if parent is Battler:
			pass
		elif parent is Base:
			if other.abilities & BattlerEnums.Abilities.BASE_DESTROYER:
				amt *= 3.0
	
	health = health - round(amt) # TODO: test if .5 rounds up or down (tbb does something wierd i think idk)
	
	if health <= 0:
		kill(attacker)


func kill(attacker: HitboxComponent):
	# TODO: death animation whatever
	if parent is Battler:
		parent.is_dying = true


func update_health_bar():
	if health_bar == null or health_label == null:
		return
	
	# reset max health because what if it changed while the battler was alive?
	# when would that happen? Archetype Battler, yeah, that guy, im planning that far ahead ok
	# or could just be a custom sandbox feature whatever
	# yeah i plan on sandbox being WAY WAY more packed than even the teased rework
	health_bar.max_value = max_health
	health_bar.value = health
	
	health_label.text = "{0}/{1}".format([health, max_health])
	
	health_bar.visible = health_visible
