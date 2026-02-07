extends Node

class_name Game

@export var chapter := GameEnums.Chapter.BrickBattle
@export var stage := 1:
	set(value):
		stage = max(value, 1)

# save what stage you are on in each chapter so game feel better idk?
var saved_stages: Dictionary[GameEnums.Chapter, int] = {}

var in_stage := false

func _ready() -> void:
	for v in GameEnums.Chapter.values():
		# auto add every chapter with a saved stage of 1, except if the export vars are set to some value use that for that specific chapter
		saved_stages[v] = stage if v == chapter else 1


func spawn_unit(unit: BattlerEnums.ID):
	pass
