extends Node3D

@onready var willie := $"../../Willie"

var inside_maze : bool = false

func _on_maze_trigger_body_entered(body: Node3D) -> void:
	if not inside_maze:
		if body is CharacterBody3D:
			willie.change_state("maze")
			inside_maze = true
