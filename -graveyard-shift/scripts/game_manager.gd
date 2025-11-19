extends Node

enum State { BOOT, MENU, LOADING, PLAYING, PAUSED, DEAD, VICTORY }

signal state_changed(prev: State, next: State)
signal scene_loaded(scene_path: String)

@export var menu_scene_path: String = "res://scenes/menu_screen.tscn"
@export var play_scene_path: String = "res://scenes/main.tscn"
@export var jumpscare_scene_path: String = "res://scenes/jumpscare.tscn"
@export var death_scene_path: String = "res//scenes/death.tscn" 
@export var victory_scene_path: String = ""  ## ADD LATER

var _state: State = State.BOOT
var _current_scene_path: String = ""
var _is_scene_changing: bool = false

func _ready() -> void:
	var cur := get_tree().current_scene
	if cur == null:
		_change_scene(menu_scene_path)
		_set_state(State.MENU)
		return
	
	var path := cur.scene_file_path
	_current_scene_path = path
	
	if path == menu_scene_path:
		_set_state(State.MENU)
	elif path == play_scene_path:
		_set_state(State.PLAYING)
	else:
		_set_state(State.MENU)
		

func get_state() -> State:
	return _state
	
	
func start_game() -> void:
	if _state == State.PLAYING or _is_scene_changing:
		return
	_set_state(State.LOADING)
	
	await _swap_to_scene(play_scene_path)
	_set_state(State.PLAYING)
	
	
func return_to_menu() -> void:
	if _is_scene_changing:
		return
	get_tree().paused = false
	await _swap_to_scene(menu_scene_path)
	_set_state(State.MENU)
	
	
func pause_game() -> void:
	if _state != State.PLAYING:
		return
	get_tree().paused = true
	_set_state(State.PAUSED)
	

func resume_game() -> void:
	if  _state != State.PAUSED:
		return
	get_tree().paused = false
	_set_state(State.PLAYING)
	
	
func player_died() -> void:
	get_tree().paused = false
	_set_state(State.DEAD)
	if death_scene_path != "":
		await _swap_to_scene(jumpscare_scene_path)


func show_death_screen() -> void:
	get_tree().paused = false
	await _swap_to_scene(death_scene_path)
	_set_state(State.DEAD)
	
	
func player_victory() -> void:
	get_tree().paused = false
	_set_state(State.VICTORY)
	if victory_scene_path != "":
		await _swap_to_scene(victory_scene_path)


func _set_state(next: State) -> void:
	if next == _state:
		return
	var prev := _state
	_state = next
	state_changed.emit(prev, next)
	
func _swap_to_scene(path: String) -> void:
	_is_scene_changing = true
	
	_change_scene(path)
	
	_is_scene_changing = false
	
func _change_scene(path: String) -> void:
	if path == "" or not ResourceLoader.exists(path):
		push_error("GameManager: scene does not exist: %s" % path)
		return
		
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("GameManager: failed to change scene -> %s (code %d)" % [path, err])
		return
	
	_current_scene_path = path
	scene_loaded.emit(path)
