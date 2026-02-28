extends CharacterBody3D

class_name Battler

# the default stuff here is referencing the stats of Battler, he is the default (obviously)
# battler id; only normal battlers exist right now
@export var id := BattlerEnums.ID.BATTLER:
	set(value):
		id = value
		_update_id()
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
@export var damage := 10
# battler attack rate
@export var attack_rate := 2.5 # wiki/in-game says 2.0 seconds, its actually 2.5 (game is lie to us? wow)
# battler range
@export var attack_range := 3:
	set(value):
		attack_range = value
		_update_attack_range()
# battler walkspeed
@export var walkspeed := 4.0

# the very awesome hidden stats or something
@export var windup := 0.15 # windup of Battler
@export var pre_windup := 0.5 # pre-windup of Battler

# magnification determines the multiplier for certain stats ONLY when updating id
var magnification := 1.0

var is_untargettable := false:
	set(value):
		is_untargettable = value
		_update_untargettable()

# untargettable + cloak effects, thats it
var is_cloaked := false:
	set(value):
		is_cloaked = value
		_update_untargettable()

var is_invincible := false # shortcut to override with 100% resistance (which still makes everything do 1 damage)
var is_true_invincible := false # true invincibility (100% resistance but 0 damage from all sources)

# doing death animation, lil' doombringers death attack does not count for this, since he is still alive, this is post-death, post-0hp, which tarnished sword's counts for this
var is_dying := false:
	set(value):
		is_dying = value
		_update_untargettable()

var disable_physics_process := false

var saved_gravity := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var abilities: int = 0 # abilities (bit flag)

var hitbox: HitboxComponent
var range_detector: RangeDetectionComponent
var health_component: HealthComponent
var attack_timer: Timer
var pivot: Node3D
var model: Node3D

# should be set by spawn_unit (which SHOULD be the only way they can spawn in)
var game: Game

enum AttackingState { NONE, PRE_WINDUP, WINDUP, ATTACKING, POST_ATTACK }

var battler_component: CoreBattlerComponent
var attacking_state := AttackingState.NONE

signal on_pre_windup() # equivalent of on enemy spotted or something idk
signal on_windup()
signal on_attack()
signal on_attack_finished() # basically called {attack_rate} seconds after on_attack() (which is when battlers usually regain movement)

# already on that boss (signals for the different parts of attack already, still working on components)

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

func _init():
	set_physics_process(false)


func _ready():
	hitbox = $HitboxComponent
	range_detector = $RangeDetectionComponent
	health_component = $HealthComponent
	attack_timer = $AttackTimer
	pivot = $Pivot
	
	assert(hitbox != null)
	assert(range_detector != null)
	assert(health_component != null)
	assert(attack_timer != null)
	assert(pivot != null)
	assert(game != null)
	
	_update_id()
	_update_is_enemy()
	_update_attack_range()
	_update_untargettable()


func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if !is_dying:
		battler_component.physics_update(delta)
	
	move_and_slide()


func start_pre_windup():
	attacking_state = AttackingState.PRE_WINDUP
	
	if pre_windup <= 0.0:
		on_pre_windup.emit()
		attack_timer.timeout.emit()
		return
	
	attack_timer.start(pre_windup)
	
	on_pre_windup.emit()


func start_windup():
	attacking_state = AttackingState.WINDUP
	
	if windup <= 0.0:
		on_windup.emit()
		attack_timer.timeout.emit()
		return
	
	attack_timer.start(windup)
	
	on_windup.emit()


func do_attack():
	attacking_state = AttackingState.ATTACKING
	
	if attack_rate <= 0.0:
		on_attack.emit()
		attack_timer.timeout.emit()
		return
	
	attack_timer.start(attack_rate)
	
	on_attack.emit()


func get_closest_enemy() -> HitboxComponent:
	return range_detector.get_closest_enemy()


func get_actual_damage() -> int:
	# TODO: account for buffs or debuffs or whatever, no weakness on the enemy does not change this value (the enemy handles that one)
	return damage


func get_actual_walkspeed() -> float:
	# TODO: account for buffs or debuffs or whatever
	return walkspeed


# can also be used for updating is_alt due to alt forms basically being a separate battler
func _update_id():
	# TODO: remove these when a proper spawning function is in place that handles stats itself and not in here i guess?
	max_health = int(BattlerEnums.get_health(id) * magnification)
	armor = int(BattlerEnums.get_armor(id) * magnification)
	resistance = BattlerEnums.get_resistance(id)
	damage = int(BattlerEnums.get_damage(id) * magnification)
	attack_rate = BattlerEnums.get_attack_rate(id)
	attack_range = BattlerEnums.get_attack_range(id)
	walkspeed = BattlerEnums.get_walkspeed(id)
	windup = BattlerEnums.get_windup(id)
	pre_windup = BattlerEnums.get_pre_windup(id)
	
	abilities = BattlerEnums.get_abilities(id)
	
	if health_component != null:
		health_component.max_health = max_health
		health_component.health = max_health
	
	if battler_component != null:
		battler_component.queue_free()
	
	battler_component = BattlerEnums.create_component(id)
	battler_component.parent = self
	
	on_pre_windup.connect(battler_component._on_pre_windup)
	on_windup.connect(battler_component._on_windup)
	on_attack.connect(battler_component._on_attack)
	on_attack_finished.connect(battler_component._on_attack_finished)
	
	if pivot != null:
		# Ok heres how it will go, every unique battler will have its own model, all 416 of them
		# Enemies? ugh, texture swap i guess, though i will have to compile some textures myself due to
		# them being a little weird with how im exporting stuff from roblox studio
		# shouldnt be a problem though, the main issue is texture swapping, but i think i have a solution
		# i dont understand why the roblox studio plugin can't handle gears, so i have to do stuff to get gear models
		var model_name := BattlerEnums.get_model_name(id)
		
		var scene: PackedScene = load("res://models/" + model_name + "/model.tscn")
		
		if scene != null:
			model = scene.instantiate()
			
			# TODO: get the mesh instance and override with proper material
			if is_enemy:
				# always an enemy material, just sometimes uses friendly texture cuz no actual enemy texture
				var enemy_material: BaseMaterial3D = load("res://models/" + model_name + "/enemy.tres")
				
				assert(enemy_material != null)
				
				var friendly_material: BaseMaterial3D = load("res://models/" + model_name + "/friendly.tres")
				
				assert(friendly_material != null)
				
				# go through all children (recursive) and change friendly_material to enemy_material
				for child in model.find_children("*", "", true, false):
					if child is MeshInstance3D:
						for i in child.mesh.get_surface_count():
							var material = child.get_active_material(i)
							
							if material == friendly_material:
								child.set_surface_override_material(i, enemy_material)
			
			pivot.add_child(model)
			
			model.position = Vector3(0, -2.5, 0)
		else:
			var mesh_instance := MeshInstance3D.new()
			
			var mesh := CapsuleMesh.new()
			mesh.radius = 1
			mesh.height = 5
			
			mesh_instance.mesh = mesh
			
			model = mesh_instance
			
			pivot.add_child(model)
	
	add_child(battler_component)


func _update_is_enemy():
	if hitbox != null:
		hitbox.is_enemy = is_enemy


func _update_attack_range():
	if range_detector != null:
		range_detector.attack_range = attack_range


func _update_max_health():
	if health_component != null:
		health_component.max_health = max_health


func _update_untargettable():
	if hitbox != null:
		hitbox.is_untargettable = is_untargettable || is_cloaked || is_dying


func _on_attack_timer_timeout() -> void:
	if is_dying:
		return
	
	match attacking_state:
		AttackingState.PRE_WINDUP:
			if range_detector.is_an_enemy_in_range():
				start_windup()
		AttackingState.WINDUP:
			do_attack()
		AttackingState.ATTACKING:
			attacking_state = AttackingState.PRE_WINDUP
			on_attack_finished.emit()
			attack_timer.timeout.emit()
