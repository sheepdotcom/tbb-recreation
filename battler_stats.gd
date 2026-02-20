extends Resource

class_name BattlerStats

static var STUPID_REGEX := RegEx.create_from_string("[^a-z_]")

@export var health: int
@export var armor: int
@export var resistance: int
@export var damage: int
@export var attack_rate: float
@export var attack_range: int
@export var walkspeed: float
@export var recharge: int
@export var cost: int
@export var windup: float
@export var pre_windup: float

# guaranteed to be at least a CoreBattlerComponent
var component: GDScript

var name: StringName
var model_name: String

func _init(health: int, armor: int, resistance: int, damage: int, attack_rate: float, attack_range: int, walkspeed: float, recharge: int, cost: int, windup: float, pre_windup: float, component: GDScript, name: StringName):
	self.health = health
	self.armor = armor
	self.resistance = resistance
	self.damage = damage
	self.attack_rate = attack_rate
	self.attack_range = attack_range
	self.walkspeed = walkspeed
	self.recharge = recharge
	self.cost = cost
	self.windup = windup
	self.pre_windup = pre_windup
	
	assert(component.new() is CoreBattlerComponent, "Component is not of CoreBattlerComponent")
	self.component = component
	
	self.name = name
	
	self.model_name = STUPID_REGEX.sub(self.name.to_lower().replace(" ", "_"), "", true)
