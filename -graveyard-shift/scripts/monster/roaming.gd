class_name Roaming
extends Monster_State


#const ROAM_DIST = 5.0
const wait = 0.15
const delay = 1.5

var prev_pos : Vector3
var time_passed : float

var dist_left : float
#var prev_dist : float


func _ready() -> void:
	monster = $"../../Willie"
	nav_mesh = $"../../Nav Regions/BigRoom".navigation_mesh.get_vertices()
	nav_map = $"../../Nav Regions/BigRoom"
	prev_pos = monster.global_position
	time_passed = 0
	
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	
	path = get_rand_path()


func action(delta:float):
	if monster.global_position.distance_to(path) <= 0.2:
		path = get_rand_path()
		_timer.start(delay)
		monster.velocity = Vector3.ZERO
		monster.animation_player.stop()
		#monster.animation_player.play("Idle/mixamo_com")
	
	#print(prev_pos.distance_to(monster.global_position))
	#dist_left = path.distance_to(monster.global_position)
	if _timer.is_stopped():
		if prev_pos.distance_to(monster.global_position) < 0.033:
			#print("WERE HERE")
			time_passed += delta
		else:
			prev_pos = monster.global_position
			#print(time_passed)
			time_passed = 0
		
		if time_passed >= wait:
			print("AHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
			time_passed = 0
			path = get_rand_path()
		
		monster.animation_player.play("Orc Walk/mixamo_com")
		set_path(path, WALK_VELOCITY)


func get_rand_path() -> Vector3:
	var random_index = randi() % nav_mesh.size()
	#print(nav_mesh[random_index])
	return Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z)
