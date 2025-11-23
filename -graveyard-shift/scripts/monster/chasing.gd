class_name Chasing
extends Monster_State


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"
	nav_mesh = $"../../NavigationRegion3D".navigation_mesh.get_vertices()
	nav_map = $"../../NavigationRegion3D"


func action(_delta:float):
	monster.animation_player.play("Injured Run/mixamo_com")
	set_path(player.global_position, RUN_VELOCITY)
