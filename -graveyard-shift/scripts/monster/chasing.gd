class_name Chasing
extends Monster_State


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"


func action(_delta:float):
	set_path(player.global_position, RUN_VELOCITY)
