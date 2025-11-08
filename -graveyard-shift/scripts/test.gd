extends CharacterBody3D

enum States {
	ROAMING,
	LOOKING,
	SEEKING,
}

enum Facing {
	NORTH,
	EAST,
	WEST,
	SOUTH,
}

#@onready var player = $"../TestingCharacter"
var player = null
@onready var nav_agent = $NavigationAgent3D

const WALK_VELOCITY = 0.5

var _facing:Facing = Facing.NORTH

#Testing variables
var timer : Timer
var temp : int

func _ready() -> void:
	#Testing stuff
	#timer = Timer.new()
	#timer.one_shot = true
	#add_child(timer)
	#timer.start(3)
	#temp = 0
	#rotation.y = temp
	player = get_node("../TestingCharacter")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#CAUSES ERROR WITH LOOKATMODIFIER
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * WALK_VELOCITY
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	##Testing stuff
	#if timer.is_stopped():
		##temp = temp + 90
		##rotation_degrees.y = temp
		#
		#if _facing == Facing.NORTH:
			#_facing = Facing.WEST
		#elif _facing == Facing.WEST:
			#_facing = Facing.SOUTH
		#elif _facing == Facing.SOUTH:
			#_facing = Facing.EAST
		#elif _facing == Facing.EAST:
			#_facing = Facing.NORTH
			#
		#timer.start(3)
		#
	## velocity.x = WALK_VELOCITY
#
	#if _facing == Facing.NORTH:
		#rotation_degrees.y = 0
		#velocity.x = 0
		#velocity.z = WALK_VELOCITY
	#elif _facing == Facing.WEST:
		#rotation_degrees.y = 90
		#velocity.x = WALK_VELOCITY
		#velocity.z = 0
	#elif _facing == Facing.SOUTH:
		#rotation_degrees.y = 180
		#velocity.x = 0
		#velocity.z = -WALK_VELOCITY
	#elif _facing == Facing.EAST:
		#rotation_degrees.y = 270
		#velocity.x = -WALK_VELOCITY
		#velocity.z = 0
#
	#print(global_position)
	
	
	move_and_slide()





func new_direction(_origin:Vector3) -> void:
	pass
