extends Node2D

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	player.DirectionChanged.connect(UpdateDirection)

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
