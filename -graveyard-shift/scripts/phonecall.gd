extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var has_started: bool = false
var has_given_code: bool = false

func _ready() -> void:
	audio_player.stop()
	audio_player.finished.connect(_on_audio_finished)

	# Register with TutorialManager so it can pause us
	if TutorialManager.has_method("set_tv"):
		TutorialManager.set_tv(self)

func interact() -> void:
	# Don't allow playing before file is placed (we're in PLACE_FILE step)
	if not _can_play_tv_now():
		return

	if has_started and audio_player.is_playing():
		return

	if not has_started:
		has_started = true
		TutorialManager.on_tv_started()

	audio_player.play()

func _can_play_tv_now() -> bool:
	# You can tighten this if you only want it usable in certain steps
	return TutorialManager.has_placed_boss_file

func _on_audio_finished() -> void:
	if has_given_code:
		return
	has_given_code = true

	# Tell tutorial that the "exit door code" is now earned
	TutorialManager.on_exit_code_found()
	TutorialManager.on_tv_finished()

func pause_video() -> void:
	if audio_player.is_playing():
		audio_player.stop()
