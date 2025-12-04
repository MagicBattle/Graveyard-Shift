class_name Storming
extends Monster_State


const time = 8.0

var listen_timer : Timer
var arrived : bool
var loudest : float
var last_loc : Vector3


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"
	nav_mesh = $"../../BigRoom".navigation_mesh.get_vertices()
	nav_map = $"../../BigRoom"
	
	listen_timer = Timer.new()
	listen_timer.one_shot = true
	add_child(listen_timer)


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 0.4 or listen_timer.is_stopped():
		monster.change_state("searching")
		monster.set_up_state(path)
	else:
		monster.animation_player.play("Injured Run/mixamo_com")
		set_path(path, RUN_VELOCITY)
	
	##IF SOUND BELOW STRENGTH 6 IS FOUND GO TO THERE BUT ONLY GO TO LOCATION IF ITS THE STRONGEST
	##SOUND HEARD OR ALREADY REACHED THE STRONGEST SPOT
	if is_equal_approx(loudest, 5.0) and last_loc.distance_to(player.global_position) <= 0.2:
		monster.change_state("chasing")


func set_up(loc : Vector3) -> void:
	path = loc
	last_loc = loc
	
	var map = nav_map.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, path)
	
	path = safe_target
	
	loudest = -1.0
	
	listen_timer.start(2.5)


func sound_heard(strength : float, loc : Vector3):
	#print("CHANGED")
	#if monster.global_position.distance_to(loc) <= 8.0:
		#if strength > loudest:
			#path = loc
			#last_loc = loc
			#loudest = strength
	path = loc
	last_loc = loc
	
	var map = nav_map.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, path)
	
	path = safe_target
	
	loudest = strength
	#print(loc, " ", path, " ", player.global_position)
