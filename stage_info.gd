extends Resource

class_name StageInfo

@export var name: StringName
@export var base_hp: int
@export var magnification: float
@export var length: int
@export var enemy_limit: int

# the id is the id of the normal version
# array of this custom type, that stores battler, tumore battler, and time till spawn
@export var enemy_cycle: Array[EnemyCycleStorer]

# no init function cuz of preload/load for .tres files, could use default parameters but at that point its doing double work (bad)
