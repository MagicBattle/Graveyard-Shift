extends Node3D

@export var grace_period : float = 0.22

@onready var start_game_trigger := $Trigger
@onready var in_zone_trigger := $SquidGame
@onready var green_light := $Decorations/GreenLight/OmniLight3D
@onready var red_light := $Decorations/RedLight/OmniLight3D
@onready var willie := $"../../Willie"

@onready var audio_player := get_node("/root/World/RedGreenLight") as AudioStreamPlayer3D

const SWAP_SOUND := preload("res://assets/briz_sounds/beep-329314.wav")
const VICTORY_SOUND := preload("res://assets/PSX Horror Audio Pack/Ambients/Backstabber.wav")
const DEFEAT_SOUND := preload("res://assets/briz_sounds/lose-sfx-365579.wav")
const ROUND_START_SOUND := preload("res://assets/briz_sounds/game-start-6104.wav")

var game_start : bool = false
var in_zone : bool = false
var go_light : bool = false
var stop_light : bool = false
var grace_timer : float = 0
var timer : Timer
var increment : float = 0.5
var reached_end : bool = false
var round_started : bool = false

# reward config (index 3)
@export var reward_code_index: int = 3
@export var reward_code_string: String = "8452"
var _given_code: bool = false

func _ready() -> void:
	$SquidGame.body_entered.connect(_on_squid_game_body_entered)
	$SquidGame.body_exited.connect(_on_squid_game_body_exited)
	$Trigger.body_entered.connect(_on_trigger_body_entered)
	
	randomize()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)


func _cinematic_red_light():
	timer.wait_time = 2.0
	red_light.light_energy = 5.0
	green_light.light_energy = 0.0

	
func _check_state():
	if green_light.light_energy == 0:
		go_light = false
		stop_light = true
	elif red_light.light_energy == 0:
		stop_light = false
		go_light = true
	

func _on_timer_timeout():
	_switch_lights()


func _random_interval():
	var r = randf_range(0.5, 3.0)
	timer.wait_time = r
	timer.start()
	
	
func _switch_lights():
	if go_light:
		red_light.light_energy = 5.0
		green_light.light_energy = 0.0
	elif stop_light:
		red_light.light_energy = 0.0
		green_light.light_energy = 5.0
	
	_play_sound(SWAP_SOUND)
	_check_state()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta: float) -> void:
	if game_start:
		_cinematic_red_light()
		game_start = false
	else:
		_check_state()
		if timer.is_stopped():
			_random_interval()
		
		if stop_light and in_zone:
			if not Input.get_vector("left", "right", "forward", "back") == Vector2.ZERO:
				#print(grace_timer)
				grace_timer += delta * increment
				if grace_timer >= grace_period:
					#Trigger some death type stuff or sound
					_call_monster()
			else:
				grace_timer = 0
		
		if go_light:
			grace_timer = 0

	
func _on_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameManager.set_phase(GameManager.Phase.RED_LIGHT)
		game_start = true
		if not round_started:
			_play_sound(ROUND_START_SOUND)
			round_started = true
	
	if body is CharacterBody3D and reached_end:
		_victory_flash()
		GameManager.set_phase(GameManager.Phase.OFFICE)
		GameManager.mark_room_completed("red_light_green_light")


func _on_squid_game_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_zone = true


func _on_squid_game_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_zone = false


func _on_end_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		reached_end = true


func _victory_flash():
	# award code once
	if not _given_code:
		_given_code = true
		Global.register_found_code(reward_code_index, reward_code_string)
		var code_ui = get_tree().current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
		if code_ui != null and code_ui.has_method("show_code"):
			code_ui.show_code(reward_code_index, reward_code_string)

	_play_sound(VICTORY_SOUND)
	$Decorations/StartLight/OmniLight3D.light_color = Color(0, 1, 0)
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 0.0
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 5.0
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 0.0
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 5.0
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 0.0
	
	await get_tree().create_timer(0.5).timeout
	
	$Decorations/StartLight/OmniLight3D.light_energy = 5.0


func _call_monster():
	_play_sound(DEFEAT_SOUND)
	willie.change_state("chasing")

func _play_sound(stream: AudioStream):
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()
