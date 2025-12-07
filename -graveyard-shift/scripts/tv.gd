extends Node3D

@onready var video_player: VideoStreamPlayer = $SubViewport/VideoStreamPlayer

var has_started: bool = false
var has_given_code: bool = false

func _ready() -> void:
	add_to_group("interactable")
	video_player.stop()
	video_player.finished.connect(_on_video_finished)

	# Register with TutorialManager so it can pause us
	if TutorialManager.has_method("set_tv"):
		TutorialManager.set_tv(self)

func interact() -> void:
	# Don't allow playing before file is placed (we're in PLACE_FILE step
	remove_from_group("interactable")
	if has_started and video_player.is_playing():
		return

	if not has_started:
		has_started = true
		TutorialManager.on_tv_started()

	video_player.play()

func _can_play_tv_now() -> bool:
	# You can tighten this if you only want it usable in certain steps
	return TutorialManager.has_placed_boss_file

func _on_video_finished() -> void:
	if has_given_code:
		return
	has_given_code = true

	# Tell tutorial that the "exit door code" is now earned
	TutorialManager.on_exit_code_found()
	TutorialManager.on_tv_finished()

func pause_video() -> void:
	if video_player.is_playing():
		video_player.stop()

func _input(event: InputEvent) -> void:
	# Allow skipping with Enter (ui_accept) while the call is playing
	if not has_started or has_given_code:
		return

	if event.is_action_pressed("ui_accept") and video_player.is_playing:
		video_player.stop()
		_on_video_finished()
