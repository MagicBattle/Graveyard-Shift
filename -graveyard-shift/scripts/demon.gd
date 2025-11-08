##TODO
##1) NEED TO FIGURE OUT A WAY TO CALCULATE THE BOUNDS OF THE MAP SO IN ROAMING
##STATE THE MONSTER DOESN'T TRY TO GO SOMEWHERE OUTSIDE OF THE MAP (THIS MIGHT
##BE ACHIEVEABLE BY USING THE NAVIGATIONREGION3D IN THE MAIN SCENE)
##2) PROPERLY IMPLEMENT LOGIC FOR EACH OF THE STATES
##3) MAKE SURE TO ADD EACH AREA TO USE WHEN CHECKING WHAT TO DO WHEN HEARING A
##SOUND

class_name Monster
extends CharacterBody3D

enum States {
	ROAMING,
	LOOKING,
	SEEKING,
}

@onready var player = $"../TestingCharacter"
@onready var nav_agent = $NavigationAgent3D

#Constants used for the monsters movement
const WALK_VELOCITY = 1.0
const RUN_VELOCITY = 4.0
const ROAM_DIST = 5.0

var curr_state : States

#variable to hold the path the monster is following in ROAMING State
var rand_path : Vector3



func _ready() -> void:
	curr_state = States.SEEKING
	rand_path = get_rand_path()


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match curr_state:
		States.ROAMING:
			if global_position.distance_to(rand_path) <= 0.5:
				rand_path = get_rand_path()
			set_path(rand_path, WALK_VELOCITY)
		States.LOOKING:
			print("IMPLEMENT")
		States.SEEKING:
			set_path(player.global_position, RUN_VELOCITY)
		
	move_and_slide()


func set_path(target : Vector3, speed : float) -> void:
	#CAUSES ERROR WITH LOOKATMODIFIER
	velocity = Vector3.ZERO
	nav_agent.set_target_position(target)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	
	look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)


func get_rand_path() -> Vector3:
	var x = randf_range(global_position.x - ROAM_DIST, global_position.x + ROAM_DIST)
	var z = randf_range(global_position.z - ROAM_DIST, global_position.z + ROAM_DIST)
	
	return Vector3(x, global_position.y, z)

func listen(location : Vector3, strength :float) -> void:
	pass
