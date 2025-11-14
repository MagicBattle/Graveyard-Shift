class_name Roaming
extends Monster_State


const ROAM_DIST = 5.0


func _ready() -> void:
	monster = $"../../Demon"
	path = get_rand_path()


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 0.5:
		path = get_rand_path()
	set_path(path, WALK_VELOCITY)


func get_rand_path() -> Vector3:
	#Gets x and z cords for random location the monster will roam to
	var x = randf_range(monster.global_position.x - ROAM_DIST, monster.global_position.x + ROAM_DIST)
	var z = randf_range(monster.global_position.z - ROAM_DIST, monster.global_position.z + ROAM_DIST)
	
	return Vector3(x, monster.global_position.y, z)
