class_name Roaming
extends Monster_State


#const ROAM_DIST = 5.0
const wait = 0.15
var prev_pos : Vector3
var time_passed : float

var dist_left : float
#var prev_dist : float


func _ready() -> void:
	monster = $"../../Willie"
	nav_mesh = $"../../NavigationRegion3D".navigation_mesh.get_vertices()
	nav_map = $"../../NavigationRegion3D"
	prev_pos = monster.global_position
	time_passed = 0
	path = get_rand_path()


func action(delta:float):
	if monster.global_position.distance_to(path) <= 0.75:
		path = get_rand_path()
	monster.animation_player.play("Orc Walk/mixamo_com")
	set_path(path, WALK_VELOCITY)
	
	#NEED TO FIND A WAY TO PREVENT FROM CONSTANTLY SWITCHING BETWEEN TWO PATHS
	#print(prev_pos.distance_to(monster.global_position))
	#dist_left = path.distance_to(monster.global_position)
	if prev_pos.distance_to(monster.global_position) < 0.03:
		#print("WERE HERE")
		time_passed += delta
	else:
		prev_pos = monster.global_position
		#print(time_passed)
		time_passed = 0
	
	if time_passed >= wait:
		#print("ENTERED")
		time_passed = 0
		path = get_rand_path()


func get_rand_path() -> Vector3:
	var random_index = randi() % nav_mesh.size()
	save = Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z)
	return Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z)
