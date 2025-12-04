extends Node3D

@onready var pause_menu = $UI/PauseMenu
@onready var player = $TestingCharacter
@onready var objective_ui = $UI/PlayerScreen/ObjectiveUI
@onready var controls_ui = $UI/PlayerScreen/ControlsUI
@export var monster_scene: PackedScene
@onready var ceo_door = $Ceo_Stuff/CeoDoor
@onready var monster_look = $Ceo_Stuff/MonsterLookAt
@onready var door_look = $Ceo_Stuff/DoorLookAt
@onready var distraction = $Ceo_Stuff/MonsterDistractionPoint
@onready var room_target = $Ceo_Stuff/RoomLookAt

var paused := false
var ambience_players: Array[AudioStreamPlayer] = []
var ambient_stinger_player: AudioStreamPlayer
var ambient_stinger_timer := 0.0
var rng := RandomNumberGenerator.new()

# NEW RANDOM MUSIC SYSTEM 
const MUSIC_TRACKS := [
	preload("res://assets/post_dream/eight.wav"),
	preload("res://assets/post_dream/eleven.wav"),
	preload("res://assets/post_dream/five.wav"),
	preload("res://assets/post_dream/nine.wav"),
	preload("res://assets/post_dream/seven.wav"),
	preload("res://assets/post_dream/ten.wav"),
	preload("res://assets/post_dream/two.wav"),
	preload("res://assets/post_dream/four.wav")
	
]

var music_player: AudioStreamPlayer
var _music_pool: Array = []


const RANDOM_AMBIENCE_DELAY_RANGE := Vector2(25.0, 55.0)
const STINGER_DURATION_RANGE := Vector2(5.0, 10.0)

const AMBIENT_STINGERS := [
	preload("res://assets/PSX Horror Audio Pack/Ambients/Backstabber.wav"),
	preload("res://assets/PSX Horror Audio Pack/Ambients/Felt_Static.wav"),
	preload("res://assets/PSX Horror Audio Pack/Ambients/Haunted.wav"),
	preload("res://assets/PSX Horror Audio Pack/Ambients/Heart_Of_Darkness.wav"),
	preload("res://assets/PSX Horror Audio Pack/Ambients/Night_Hunter.wav")
]

const WIND_AMBIENCE: AudioStream = preload("res://assets/horror_sfx_vol_1/Ambient Wind/Ambient Wind (7).mp3")
const DUCT_RUMBLE: AudioStream = preload("res://assets/horror_sfx_vol_1/Ambient Wind/Ambient Wind (5).mp3")

func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	_on_state_changed(GameManager.get_state(), GameManager.get_state())
	TutorialManager.begin(player, objective_ui, controls_ui)
	TutorialManager.set_ceo_door(ceo_door)
	TutorialManager.set_look_targets(monster_look, door_look, room_target)
	TutorialManager.set_monster_scene(monster_scene)  
	TutorialManager.set_monster_distraction_target(distraction)

	_ensure_ambient_bed()
	_setup_ambient_stingers()
	_setup_music_system()  # NEW

func _process(delta: float) -> void:
	if GameManager.get_state() != GameManager.State.PLAYING:
		return

	_update_ambient_stingers(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var state: GameManager.State = GameManager.get_state()
		if state == GameManager.State.PLAYING:
			GameManager.pause_game()

func _on_state_changed(prev: GameManager.State, next: GameManager.State) -> void:
	var is_paused := (next == GameManager.State.PAUSED)
	pause_menu.visible = is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif next == GameManager.State.PLAYING:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# music
func _setup_music_system() -> void:
	if MUSIC_TRACKS.is_empty():
		return

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.autoplay = false
	music_player.volume_db = -8.0
	add_child(music_player)

	_reset_music_pool()
	_play_next_music_track()

	music_player.finished.connect(_play_next_music_track)

func _reset_music_pool() -> void:
	_music_pool = MUSIC_TRACKS.duplicate()
	rng.randomize()
	_music_pool.shuffle()

func _play_next_music_track() -> void:
	if _music_pool.is_empty():
		_reset_music_pool()

	var track = _music_pool.pop_back()
	music_player.stream = track
	music_player.pitch_scale = rng.randf_range(0.98, 1.02)
	music_player.play()

func _ensure_ambient_bed() -> void:
	_add_looping_ambience("WindBed", WIND_AMBIENCE, -13.0, 0.9)
	_add_looping_ambience("DuctRumble", DUCT_RUMBLE, -17.0, 1.05)

func _setup_ambient_stingers() -> void:
	rng.randomize()

	# Player for stinger audio
	ambient_stinger_player = AudioStreamPlayer.new()
	ambient_stinger_player.name = "AmbientStinger"
	ambient_stinger_player.volume_db = -10.0
	add_child(ambient_stinger_player)

	# Timer to auto-stop stingers after a short random burst
	var stop_timer := Timer.new()
	stop_timer.name = "StingerStopTimer"
	stop_timer.wait_time = _random_stinger_duration()
	stop_timer.one_shot = true
	stop_timer.timeout.connect(_stop_stinger)
	add_child(stop_timer)

	_schedule_next_stinger()

func _update_ambient_stingers(delta: float) -> void:
	if ambient_stinger_player == null or AMBIENT_STINGERS.is_empty():
		return

	ambient_stinger_timer -= delta

	if ambient_stinger_timer <= 0.0:
		_play_random_stinger()
		_schedule_next_stinger()

func _play_random_stinger() -> void:
	var index := rng.randi_range(0, AMBIENT_STINGERS.size() - 1)
	ambient_stinger_player.stream = AMBIENT_STINGERS[index]

	ambient_stinger_player.pitch_scale = rng.randf_range(0.96, 1.04)
	ambient_stinger_player.play()

	# Restart stop timer for a randomized 5–10 second cutoff
	var t := $StingerStopTimer
	t.stop()
	t.wait_time = _random_stinger_duration()
	t.start()

func _stop_stinger() -> void:
	if ambient_stinger_player.playing:
		ambient_stinger_player.stop()

func _random_stinger_duration() -> float:
	return rng.randf_range(
		STINGER_DURATION_RANGE.x,
		STINGER_DURATION_RANGE.y
	)

func _schedule_next_stinger() -> void:
	ambient_stinger_timer = rng.randf_range(
		RANDOM_AMBIENCE_DELAY_RANGE.x,
		RANDOM_AMBIENCE_DELAY_RANGE.y
	)

func _add_looping_ambience(name: String, stream: AudioStream, volume: float, pitch: float = 1.0) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.name = name
	player.stream = stream

	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true

	player.autoplay = true
	player.volume_db = volume
	player.pitch_scale = pitch

	add_child(player)
	ambience_players.append(player)
