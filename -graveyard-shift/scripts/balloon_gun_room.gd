extends Node3D

var Balloon = preload("res://scenes/balloon.tscn")

var PAPER_BALL_ITEM := {
	"type": "throwable",
	"scene": preload("res://scenes/throwable.tscn")  # use real throwable scene here
}

var start_game : bool = false
var timer : Timer
var level : int = 1
var done_with_level : bool = false
var done_with_game : bool = false
var fire_once : bool = false
var check_throwable : bool = false

func _process(delta):
	if not timer == null and not done_with_game:
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
	var paper_ball = preload("res://assets/PSX_OFFICE_GLTF/Paper Ball/Paper Ball.glb")
	var mesh = _get_mesh(paper_ball)
	var scales = Vector3(0.2, 0.2, 0.2)
	throwable_instance.set_mesh_and_collision(mesh, scales)
	add_child(throwable_instance)
	throwable_instance.set("type", "throwable")
	throwable_instance.add_to_group("throwables")
	#throwable_instance.add_to_group("pickup_throwable")
		
	
func _spawn_level():
	_spawn_throwable()
	if level == 1:
		for i in range(3):
			_spawn_a_balloon()
		_start_timer(15)
	elif level == 2:
		for i in range(5):
			_spawn_a_balloon()

		_start_timer(30)
	elif level == 3:
		for i in range(8):
			_spawn_a_balloon()
		_start_timer(45)


func _start_timer(seconds : float):
	if timer == null:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_time_end"))
		
	timer.wait_time = seconds
	timer.start()


func _on_time_end():

	_check_if_complete()
	
	if not done_with_level:
		print("You die")
		_call_monster()
		for balloon in get_tree().get_nodes_in_group("balloons"):
			balloon.queue_free()
		for throw in get_tree().get_nodes_in_group("throwables"):
			throw.queue_free()

func _call_monster():
	pass
	#Loud sound queue
	

func _check_if_complete():
	if get_tree().get_nodes_in_group("balloons").size() == 0:
		done_with_level = true
		if not timer == null and timer.is_stopped() == false:
			timer.stop()
		
		await get_tree().create_timer(1.0).timeout
		for balloon in get_tree().get_nodes_in_group("balloons"):
			balloon.queue_free()
		for throw in get_tree().get_nodes_in_group("throwables"):
			throw.queue_free()
			
		_next_level()


func _next_level():
	done_with_level = false
	level += 1
	if level > 3:
		done_with_game = true
		print("Fuck yea")
	else:
		_spawn_level()
		
		
func _on_balloon_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_game = true
		if not fire_once:
			_spawn_level()
			fire_once = true


func _on_throwable_spawn_zone_body_exited(body: Node3D) -> void:
	if body is RigidBody3D and not done_with_game:
		_spawn_throwable()
