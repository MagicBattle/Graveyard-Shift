class_name Chasing
extends Monster_State


func _ready() -> void:
	monster = $"../../Willie v2"
	player = $"../../TestingCharacter"


func action(_delta:float):
	monster.animation_player.play("chase/b083-runtoblastb")
	set_path(player.global_position, RUN_VELOCITY)
