extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var ring_player: AudioStreamPlayer3D = $RingCaller

var has_started: bool = false
var done: bool = false

func _ready() -> void:
	audio_player.stop()
	audio_player.finished.connect(_on_audio_finished)
	add_to_group("interactable")
	
	if ring_player:
		ring_player.stop()
		if ring_player.stream is AudioStreamMP3:
			(ring_player.stream as AudioStreamMP3).loop = true
	
	# Register with TutorialManager so it can talk to the phone
	if TutorialManager.has_method("set_phone"):
		TutorialManager.set_phone(self)

func start_ringing() -> void:
	if ring_player and ring_player.stream:
		print("play")
		if not ring_player.playing:
			ring_player.play()


func stop_ringing() -> void:
	if ring_player and ring_player.playing:
		ring_player.stop()


func interact() -> void:
	# Only usable during the PHONE_CALL step of the tutorial
	if not _can_play_phone_now():
		return

	if done:
		return
	
	# Already playing → do nothing
	if has_started and audio_player.playing:
		return
	
	if not has_started:
		has_started = true
		stop_ringing()
		if TutorialManager.has_method("on_phone_started"):
			TutorialManager.on_phone_started()
	
	audio_player.play()
	
	remove_from_group("interactable")

func _can_play_phone_now() -> bool:
	# Phone is only part of the tutorial, not general office
	return TutorialManager.active \
		and TutorialManager.step == TutorialManager.Step.PHONE_CALL


func _input(event: InputEvent) -> void:
	# Allow skipping with Enter (ui_accept) while the call is playing
	if not has_started or done:
		return

	if event.is_action_pressed("ui_accept") and audio_player.playing:
		audio_player.stop()
		_on_audio_finished()


func _on_audio_finished() -> void:
	if done:
		return
	done = true
	remove_from_group("interactable")

	# Tell the tutorial the call is over → advance to "Michael's desk" step
	TutorialManager.on_phone_finished()
