extends Node

enum State { BOOT, MENU, LOADING, PLAYING, PAUSED, DEAD, VICTORY }
enum Phase { TUTORIAL, OFFICE, RED_LIGHT, SIMON_SAYS, BALLOON_POP, TWOD_GAME, FINAL, FAIL }

signal state_changed(prev: State, next: State)
signal scene_loaded(scene_path: String)
signal room_marked_completed(room_id: String)
signal phase_changed(prev: Phase, next: Phase)

@export var menu_scene_path: String = "res://scenes/menu_screen.tscn"
@export var play_scene_path: String = "res://scenes/main.tscn"
@export var jumpscare_scene_path: String = "res://scenes/jumpscare.tscn"
@export var death_scene_path: String = "res://scenes/death.tscn" 
@export var victory_scene_path: String = ""  ## ADD LATER
@export var death_room_order: Array[String] = [
	"tutorial",
	"book_code",
	"red_light_green_light",
	"simon_says",
	"balloon_pop",
	"twod_game",
	"final_puzzle",
]

var _state: State = State.BOOT
var _current_scene_path: String = ""
var _is_scene_changing: bool = false
var _rooms_completed: Dictionary = {}
var _phase: Phase = Phase.TUTORIAL



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


func mark_room_completed(room_id: String) -> void:
	_rooms_completed[room_id] = true
	room_marked_completed.emit(room_id)
	
	
func is_room_completed(room_id: String) -> bool:
	return _rooms_completed.get(room_id, false)
	
func can_unlock_room(room_id: String) -> bool:
	var idx := death_room_order.find(room_id)
	if idx == -1:
		return true
	if idx == 0:
		return true
		
	var prev_id := death_room_order[idx - 1]
	return is_room_completed(prev_id)
	
func _reset_run_progress() -> void:
	_rooms_completed.clear()
	_phase = Phase.TUTORIAL
	
	
func start_game() -> void:
	if _state == State.PLAYING or _is_scene_changing:
		return
	_set_state(State.LOADING)

	await _swap_to_scene(play_scene_path)
	_set_state(State.PLAYING)
	if is_room_completed("tutorial"):
		set_phase(Phase.OFFICE)


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
	if _state != State.PAUSED:
		return
	get_tree().paused = false
	var player := get_tree().current_scene.get_node_or_null("TestingCharacter")
	player.ignore_throw_input = true
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

func show_menu_screen() -> void:
	get_tree().paused = false
	await _swap_to_scene(menu_scene_path)
	_set_state(State.MENU)
# Game Phase Helpers
func get_phase() -> Phase:
	return _phase
	

func set_phase(next: Phase) -> void:
	_set_phase(next)
	
	
func _set_phase(next: Phase) -> void:
	if next == _phase:
		return
	var prev: Phase = _phase
	_phase = next
	phase_changed.emit(prev, next)
	
func is_minigame_active() -> bool:
	return _phase == Phase.RED_LIGHT \
		or _phase == Phase.SIMON_SAYS \
		or _phase == Phase.BALLOON_POP \
		or _phase == Phase.TWOD_GAME \
		or _phase == Phase.FINAL

# Game State Helpers
func get_state() -> State:
	return _state


func _set_state(next: State) -> void:
	if next == _state:
		return
	var prev := _state
	_state = next
	state_changed.emit(prev, next)


# called when we come back from the 2D arcade
func force_playing_state_after_return() -> void:
	get_tree().paused = false
	_set_state(State.PLAYING)


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

# how I connected the code 
# 1) When entering the 2D game (enter once you press interact with arcade, start game on main menu, and resume on pause
# Anywhere the player starts the 2D game:
# GameManager.set_phase(GameManager.Phase.TWOD_GAME)

# 2) When exiting the 2D game (pause menu quit or main menu return): 
# GameManager.set_phase(GameManager.Phase.OFFICE)

# 3) When the player wins the 2D game: #connected to the area 3d dialogue 
# GameManager.mark_room_completed("twod_game")
