extends Node3D

@onready var particles = $balloon/BalloonPopParticles
@onready var audio_player := get_node("/root/World/Balloon") as AudioStreamPlayer3D

const POP_SOUND := preload("res://assets/briz_sounds/balloon-burst-383750.wav")

func _pop_balloon():
	_play_sound(POP_SOUND)
	$balloon/Cone_001.visible = false
	particles.one_shot = true
	$balloon/Cone_001.visible = false
	particles.one_shot = true
	particles.emitting = true
	particles.initial_velocity_min = 5.0
	particles.spread = 180
	particles.direction = Vector3.UP
	
	if particles.one_shot:
		while particles.emitting:
			await get_tree().process_frame
		
	

func _on_pop_trigger_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		await _pop_balloon()
		queue_free()

func _play_sound(stream: AudioStream):
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()
