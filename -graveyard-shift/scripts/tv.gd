extends Node3D

@onready var video_player: VideoStreamPlayer = $SubViewport/VideoStreamPlayer

var has_started: bool = false  # makes it so it only plays once

func _ready() -> void:
	# make sure it does not autoplay at start
	video_player.stop()

func interact() -> void:
	# called by player when pressing F on the TV
	if has_started:
		return
	has_started = true
	video_player.play()
