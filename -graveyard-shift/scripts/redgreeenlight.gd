extends Node3D

@export var grace_period : float = 0.22

@onready var start_game_trigger := $Trigger
@onready var in_zone_trigger := $SquidGame
@onready var green_light := $Decorations/GreenLight/OmniLight3D
@onready var red_light := $Decorations/RedLight/OmniLight3D

var game_start : bool = false
var in_zone : bool = false
var go_light : bool = false
var stop_light : bool = false
var grace_timer : float = 0
var timer : Timer
var increment : float = 0.5

# Called when the node enters the scene tree for the first time.
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
	var r = randf_range(0.3, 3.0)
	timer.wait_time = r
	timer.start()
	
	
func _switch_lights():
	if go_light:
		red_light.light_energy = 5.0
		green_light.light_energy = 0.0
	elif stop_light:
		red_light.light_energy = 0.0
		green_light.light_energy = 5.0
	
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
			if (get_node("/root/World/TestingCharacter")).velocity.length() > 0.065:
				grace_timer += delta * increment
				if grace_timer >= grace_period:
					#Trigger some death type stuff or sound
					print("FAIL")
			else:
				grace_timer = 0
		
		if go_light:
			grace_timer = 0

	
func _on_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		game_start = true


func _on_squid_game_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_zone = true


func _on_squid_game_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		in_zone = false
