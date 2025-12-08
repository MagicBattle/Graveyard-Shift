extends Node3D

@onready var video_player: VideoStreamPlayer = $SubViewport/VideoStreamPlayer

var has_started: bool = false  

func _ready() -> void:
	video_player.stop()

func interact() -> void:
	# Called when the player presses the interact button 
	if has_started:
		return
	has_started = true
	video_player.play()
