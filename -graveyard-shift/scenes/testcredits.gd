extends Node3D

@onready var world := $WorldEnvironment
@onready var env = world.environment


func _ready() -> void:
	await _fade_in()

func _fade_in():
	var fade = get_tree().create_tween()
	fade.tween_property(env, "adjustment_brightness", 1, 5.0)
	

	
