extends Area3D

@onready var col := $".."

const active = 1.5

var prev_pos : Vector3
var _timer : Timer
var first : bool


func _ready() -> void:
	#Using this value as given our map there is no way for it to get close to this point
	#resulting in no potential triggers of if statements when unwanted
	prev_pos = Vector3(-1000, -1000, -1000)
	
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	
	first = true

func _on_body_entered(body: Node3D) -> void:
	if first:
		#print(body)
		start()
	
	if body is not RigidBody3D:
		#if is_equal_approx(global_position.distance_to(prev_pos), 0.0):
			#print("DONE")
		#else:
			#NoiseManager.emit_signal("noise_emitted", global_position, 8)
		#prev_pos = body.global_position
		if !_timer.is_stopped():
			#print("EMITTED")
			NoiseManager.emit_signal("noise_emitted", global_position, 8)
		#if _timer.is_stopped():
			#print("DONE")
	if body is CharacterBody3D:
		#body.add_collision_exception_with(self)
		col.add_collision_exception_with(body)


func start() -> void:
	#print("STARTED")
	_timer.start(active)
	first = false
