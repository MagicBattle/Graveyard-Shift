class_name Maze
extends Monster_State


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"
	nav_mesh = $"../../BigRoom".navigation_mesh.get_vertices()
	nav_map = $"../../BigRoom"


func action(_delta:float):
	print("CHASING")
	monster.animation_player.play("Injured Run/mixamo_com")
	chase_set_path(player.global_position, MAZE_VELOCITY)
