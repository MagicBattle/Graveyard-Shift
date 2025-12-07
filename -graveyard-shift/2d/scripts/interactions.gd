# interactions.gd
extends Node2D

# assuming the player node is the parent; adjust path if needed
@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	player.DirectionChanged.connect(UpdateDirection)
	pass 
	
func UpdateDirection(new_direction: String) -> void:
	match new_direction:
		"down":
			rotation_degrees = 0 
		"up":
			rotation_degrees = 180 
		"left":
			rotation_degrees = 90 
		"right":
			rotation_degrees = -90 
		_:
			rotation_degrees = 0
	pass
