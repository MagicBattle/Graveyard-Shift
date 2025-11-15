class_name Chasing
extends Monster_State


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"


func action(_delta:float):
	monster.animation_player.play("Injured Run/mixamo_com")
	set_path(player.global_position, RUN_VELOCITY)
