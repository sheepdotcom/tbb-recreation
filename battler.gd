extends CharacterBody3D

class_name Battler

# the default stuff here is referencing the stats of Battler, he is the default (obviously)
# battler id; only normal battlers exist right now
@export var id := BattlerEnums.ID.BATTLER
# is the battler in their alt form (not implemented yet)
@export var is_alt := false
# is the battler an enemy
@export var is_enemy := false:
	set(value):
		is_enemy = value
		_update_is_enemy()
# battler health
@export var max_health := 50:
	set(value):
		max_health = value
		_update_max_health()
# battler armor
@export var armor := 0
# battler resistance
@export var resistance := 0
# battler damage
@export var damage := 0
# battler attack rate
@export var attack_rate := 2.2 # wiki/in-game says 2.0 seconds, from video battler has 2.6 seconds (are they lying to us???)
# battler range
@export var attack_range := 3:
	set(value):
		attack_range = value
		_update_attack_range()
# battler walkspeed
@export var walkspeed := 4.0
# battler's hidden windup or whatever
@export var windup := 0.15 # wiki said 0.15 seconds, from video it was 9 frames (0.15 seconds)
# battler's hidden pre-windup or something idk, like when battlers stop for 0.5 seconds before attacking
# though some battlers have this at 0 or something (like jetpack)
@export var pre_windup := 0.53 # guess was 0.5 seconds, from video i think its 32 frames (0.5333 seconds)
# also 24 frames of animation after attacking (0.4 seconds)
# and the attack rate then is 132 frames? (2.2 seconds) or 156 frames counting the post-windup animation (2.6 seconds)
# either i got a bug or sword battler has 0 seconds of pre windup causing his attack animation to happen after windup is finished
# attack rate for sword battler is 63 frames? (1.05 seconds)
# most likely be a 3 frame after pre windup windup or something idk
# sword battler has no pre windup, he instantly attacks (animation bugs a little though)

var hitbox: HitboxComponent
var range_detector: RangeDetectionComponent
var health_component: HealthComponent
var attack_timer: Timer

enum AttackingState { NONE, PRE_WINDUP, WINDUP, ATTACKING }

var attack_component: BaseAttackComponent
var attacking_state := AttackingState.NONE

signal on_pre_windup() # equivalent of on enemy spotted or something idk
signal on_windup()
signal on_attack()
signal on_attack_finished() # basically called {attack_rate} seconds after on_attack() (which is when battlers usually regain movement)

# IMPORTANT: HOW TO HANDLE BATTLERS WITH CUSTOM MECHANICS
# here is a way as an example: Telamon Battler
# telamon battler heals after his attack, so the solution i think would be a component
# that is to handle the healing thing, with a function that triggers after attack, and then
# have a signal in battler for like after attacking and the telamon component listens for that
# and triggers its thing, and we could do that for other things like battlers that need to reload
# like they could also have an after attack trigger that detects if they used up all their ammo
# also winged/jetpack battler could have their own component that stores a timer
# how would the components be added? checks that happen in an _update_id() function or something
# which would replace the components (like switching from telamon to jetpack would delete the telamon
# component to then add the jetpack one), or just add or delete them, also remember to use
# the thing used in HealthComponent to add its children to the component where it is used so children
# are kept, you know what I mean (its what is done in HealthComponent so the health bar shows up)

func _ready():
	hitbox = $HitboxComponent
	range_detector = $RangeDetectionComponent
	health_component = $HealthComponent
	attack_timer = $AttackTimer
	
	assert(hitbox != null)
	assert(range_detector != null)
	assert(health_component != null)
	assert(attack_timer != null)
	
	_update_id()
	_update_is_enemy()
	_update_attack_range()
	_update_max_health()


func _physics_process(_delta: float) -> void:
	# for movement later do something with vectors and also handle walkspeed (de)buffs
	# (later) basically assume left is the direction we want to go and apply stuff
	# (later) then apply is_enemy onto it so enemies go right
	# (later) this is to handle things like fear or whatever else (when implemented)
	if !range_detector.enemies_in_range.is_empty() || attacking_state >= AttackingState.WINDUP:
		velocity = _physics_attacking()
	else:
		# cancel prewindup if enemy exits range
		if attacking_state == AttackingState.PRE_WINDUP:
			attacking_state = AttackingState.NONE
			attack_timer.stop()
		
		velocity = _physics_not_attacking()
	move_and_slide()


# runs every _physics_process when not attacking, returns the velocity of the battler
func _physics_not_attacking() -> Vector3:
	var new_velocity := Vector3.ZERO
	
	new_velocity.x = walkspeed

	if !hitbox.is_enemy:
		new_velocity.x = -new_velocity.x

	# currently just rotate the battler to face direction of movement
	# (later) rotate towards target enemy when attacking
	# (later) about above: rotate towards where enemy last way until battler is done attacking or whatever (when they can start moving/attack again)
	if new_velocity != Vector3.ZERO:
		$Pivot.basis = Basis.looking_at(new_velocity)
	
	return new_velocity


# runs every _physics_process when attacking, returns the velocity of the battler
func _physics_attacking() -> Vector3:
	var new_velocity := Vector3.ZERO
	
	# start the pre-windup
	if attacking_state == AttackingState.NONE:
		start_pre_windup()
	
	# the rest is handled by timer and prewindup also by _physics_process
	
	return new_velocity


func start_pre_windup():
	attacking_state = AttackingState.PRE_WINDUP
	
	print("pre winding up!")
	attack_timer.start(pre_windup)
	
	on_pre_windup.emit()


func start_windup():
	attacking_state = AttackingState.WINDUP
	
	print("winding up!")
	attack_timer.start(windup)
	
	on_windup.emit()


func do_attack():
	attacking_state = AttackingState.ATTACKING
	
	print("BONK!")
	attack_timer.start(attack_rate)
	
	on_attack.emit()


func get_closest_enemy() -> HitboxComponent:
	# (later) do some math to figure out what the closest point would be on certain shapes
	# for now we do center to center check but subtract radius as a very basic way to determine edge to edge distance
	var closest_enemy: HitboxComponent = null
	var smallest_distance := INF
	
	# find closest enemy
	for enemy in range_detector.enemies_in_range:
		var distance = enemy.position.distance_squared_to(position)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy


func get_actual_damage() -> int:
	# TODO: account for buffs or debuffs or whatever, no weakness on the enemy does not change this value (the enemy handles that one)
	return damage


# can also be used for updating is_alt due to alt forms basically being a separate battler
func _update_id():
	# TODO: remove these when a proper spawning function is in place that handles stats itself and not in here i guess?
	max_health = BattlerEnums.get_health(id, is_alt)
	armor = BattlerEnums.get_armor(id, is_alt)
	resistance = BattlerEnums.get_resistance(id, is_alt)
	damage = BattlerEnums.get_damage(id, is_alt)
	attack_rate = BattlerEnums.get_attack_rate(id, is_alt)
	attack_range = BattlerEnums.get_attack_range(id, is_alt)
	walkspeed = BattlerEnums.get_walkspeed(id, is_alt)
	windup = BattlerEnums.get_windup(id, is_alt)
	pre_windup = BattlerEnums.get_pre_windup(id, is_alt)
	
	if attack_component != null:
		attack_component.queue_free()
	
	attack_component = BattlerEnums.create_component(id, is_alt)
	attack_component.parent = self
	
	on_pre_windup.connect(attack_component._on_pre_windup)
	on_windup.connect(attack_component._on_windup)
	on_attack.connect(attack_component._on_attack)
	on_attack_finished.connect(attack_component._on_attack_finished)
	
	add_child(attack_component)


func _update_is_enemy():
	if hitbox != null:
		hitbox.is_enemy = is_enemy


func _update_attack_range():
	if range_detector != null:
		range_detector.attack_range = attack_range


func _update_max_health():
	if health_component != null:
		health_component.max_health = max_health


func _on_attack_timer_timeout() -> void:
	match attacking_state:
		AttackingState.PRE_WINDUP:
			if !range_detector.enemies_in_range.is_empty():
				start_windup()
		AttackingState.WINDUP:
			do_attack()
		AttackingState.ATTACKING:
			attacking_state = AttackingState.PRE_WINDUP
			on_attack_finished.emit()
			attack_timer.timeout.emit()
