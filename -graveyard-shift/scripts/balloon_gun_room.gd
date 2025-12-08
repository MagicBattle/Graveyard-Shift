extends Node3D

@onready var willie := $"../../Willie"

var Balloon = preload("res://scenes/balloon.tscn")

#Sounds
const ROUND_START_SOUND := preload("res://assets/briz_sounds/game-start-6104.wav")
const VICTORY_SOUND := preload("res://assets/briz_sounds/victory-chime-366449.wav")
const DEFEAT_SOUND := preload("res://assets/briz_sounds/lose-sfx-365579.wav")

@onready var audio_player := get_node("/root/World/Balloon") as AudioStreamPlayer3D

var PAPER_BALL_ITEM := {
	"type": "throwable",
	"scene": preload("res://scenes/paper_throwable.tscn"),  # use real throwable scene here
	"icon_path": "res://icons/paper_ball_icon.png",
	"mesh": preload("res://assets/PSX_OFFICE_GLTF/Paper Ball/Paper Ball.glb")
}

var start_game : bool = false
var timer : Timer
var level : int = 1
var done_with_level : bool = false
var done_with_game : bool = false
var fire_once : bool = false
var check_throwable : bool = false
var fail : bool = false
var throwables_in_zone : Array[RigidBody3D] = []

#reward config (index 5)
@export var reward_code_index: int = 5
@export var reward_code_string: String = "1993"
var _given_code: bool = false

func _process(delta):
	if not timer == null and not done_with_game and not fail:
		print(timer.time_left)
	
	if not done_with_level and start_game and not done_with_game:
		if get_tree().get_nodes_in_group("balloons").size() == 0:
			_check_if_complete()
		
		
func _spawn_a_balloon():
	var x = randf_range(0,8)
	var y = randf_range(0,0.2)
	var z = randf_range(-12, 5)
	var local_pos = Vector3(x,y,z)
	var balloon_instance = Balloon.instantiate()
	balloon_instance.position = local_pos
	balloon_instance.add_to_group("balloons")
	add_child(balloon_instance)

func _get_mesh(glb_scene : PackedScene):
	var inst = glb_scene.instantiate()
	
	var mesh_ins = inst.find_child("Paper Ball", true, false) as MeshInstance3D
	
	if mesh_ins:
		return mesh_ins.mesh
		
	return null


func _spawn_throwable():
	var x = randf_range(-3.8,-3.9)
	var y = randf_range(1.0,1.5)
	var z = randf_range(-4, 0)
	var local_pos = Vector3(x,y,z)
	var throwable_instance = PAPER_BALL_ITEM.scene.instantiate()
	throwable_instance.global_transform.origin = local_pos
	
	add_child(throwable_instance)
	throwable_instance.set("type", "throwable")
	throwable_instance.add_to_group("throwables")
	throwable_instance.add_to_group("pickup_throwable")
		
	
func _spawn_level():
	if not fail:
		_play_sound(ROUND_START_SOUND)
		_spawn_throwable()
	if level == 1:
		for i in range(3):
			_spawn_a_balloon()
	_start_timer(15)
	if not fail:
		_spawn_throwable()
		if level == 1:
			for i in range(3):
				_spawn_a_balloon()
			_start_timer(21)
		elif level == 2:
			for i in range(5):
				_spawn_a_balloon()
			_start_timer(25)
			
		elif level == 3:
			for i in range(8):
				_spawn_a_balloon()
			_start_timer(35)


func _start_timer(seconds : float):
	if timer == null:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_time_end"))
		
	timer.wait_time = seconds
	timer.start()


func _on_time_end():
	if not get_tree().get_nodes_in_group("balloons").size() == 0:
		fail = true
		_play_sound(DEFEAT_SOUND)
		_call_monster()
	for balloon in get_tree().get_nodes_in_group("balloons"):
		balloon.queue_free()
	if not get_tree().get_nodes_in_group("balloons").size() == 0:
		fail = true	
		_call_monster()
		for balloon in get_tree().get_nodes_in_group("balloons"):
			balloon.queue_free()
		for throw in get_tree().get_nodes_in_group("throwables"):
			throw.queue_free()


func _call_monster():
	willie.change_state("chasing")
	#Loud sound queue
	

func _check_if_complete():
	if level > 3:
		done_with_game = true
		if not timer == null and timer.is_stopped() == false:
			timer.stop()
		_next_level()
			
	if get_tree().get_nodes_in_group("balloons").size() == 0 and not fail:
		done_with_level = true
		if not timer == null and timer.is_stopped() == false:
			timer.stop()
			
		_next_level()
		


func _next_level():
	done_with_level = false
	level += 1
	if level > 3:
		_victory_flash()
		_play_sound(VICTORY_SOUND)
	if done_with_game and not fail:
		for balloon in get_tree().get_nodes_in_group("balloons"):
			balloon.queue_free()
	done_with_level = false
	level += 1
	if level > 3:
		_victory_flash()
		if done_with_game and not fail:
			for balloon in get_tree().get_nodes_in_group("balloons"):
				balloon.queue_free()
			for throw in get_tree().get_nodes_in_group("throwables"):
				throw.queue_free()
		done_with_game = true
	else:
		_spawn_level()
		
		
func _on_balloon_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_game = true
		if not fire_once:
			_spawn_level()
			fire_once = true


func _on_throwable_spawn_zone_body_exited(body: Node3D) -> void:
	if body is RigidBody3D and not done_with_game and not fail:
		throwables_in_zone.erase(body)
		if throwables_in_zone.is_empty():
			_spawn_throwable()


func _on_throwable_spawn_zone_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and not done_with_game and not fail:
		throwables_in_zone.append(body)
	if body is RigidBody3D	and done_with_game:
		for throw in get_tree().get_nodes_in_group("throwables"):
			throw.queue_free()
				
				
func _disable_old(node : Node):
	if node is CollisionShape3D:
		node.disabled = true
	for child in node.get_children():
		_disable_old(child)


func _victory_flash():
	# award code once
	if not _given_code:
		_given_code = true
		Global.register_found_code(reward_code_index, reward_code_string)
		var code_ui = get_tree().current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
		if code_ui != null and code_ui.has_method("show_code"):
			code_ui.show_code(reward_code_index, reward_code_string)

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

func _play_sound(stream: AudioStream):
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()
