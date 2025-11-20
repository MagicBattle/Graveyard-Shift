class_name Monster_State
extends Node

#@export var monster : Monster
@onready var player = $"../TestingCharacter"

#Constants used for the monsters movement
const WALK_VELOCITY = 1.0
const RUN_VELOCITY = 4.0

var monster : Monster
var path : Vector3
var nav_mesh : PackedVector3Array
var nav_map : NavigationRegion3D
var save : Vector3 = Vector3.ZERO

# Class used to give a template for what each Monster_State should have


func _ready() -> void:
	pass 


func action(_delta:float):
	pass


func set_path(target : Vector3, speed : float) -> void:
	#CAUSES ERROR WITH LOOKATMODIFIER
	
	monster.velocity = Vector3.ZERO
	
	#sets the navigation agent to the target location
	monster.nav_agent.set_target_position(target)
	
	#We only need the next position on the path to find the velocity we need
	var next_nav_point = monster.nav_agent.get_next_path_position()
	var map = nav_map.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, next_nav_point)
	
	if safe_target != save:
		print("NAV POINT: ", safe_target)
		save = safe_target
	
	monster.velocity = (safe_target - monster.global_transform.origin).normalized() * speed
	
	monster.look_at(Vector3(target.x, monster.global_position.y, target.z), Vector3.UP)
	#print("VELOCITY: ", monster.velocity)
	#print("NEXT: ", safe_target)
