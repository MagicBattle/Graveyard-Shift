class_name Roaming
extends Monster_State


const ROAM_DIST = 5.0


func _ready() -> void:
	monster = $"../../Willie"
	nav_mesh = $"../../NavigationRegion3D".navigation_mesh.get_vertices()
	nav_map = $"../../NavigationRegion3D"
	path = get_rand_path()


func action(_delta:float):
	#print(monster.global_position.distance_to(path))
	if monster.global_position.distance_to(path) <= 0.75:
		#print("FINISHED")
		path = get_rand_path()
	monster.animation_player.play("Orc Walk/mixamo_com")
	#print(monster.global_position, " ", save)
	set_path(path, RUN_VELOCITY)


func get_rand_path() -> Vector3:
	#Gets x and z cords for random location the monster will roam to
	#var x = randf_range(monster.global_position.x - ROAM_DIST, monster.global_position.x + ROAM_DIST)
	#var z = randf_range(monster.global_position.z - ROAM_DIST, monster.global_position.z + ROAM_DIST)
	#var loc = Vector3(x, monster.global_position.y, z)
	#
	#var map = nav_map.get_navigation_map()
	#
	#var safe_target = NavigationServer3D.map_get_closest_point(map, loc)
	#
	#return safe_target
	var random_index = randi() % nav_mesh.size()
	save = Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z)
	return Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z)
