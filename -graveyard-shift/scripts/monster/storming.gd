class_name Storming
extends Monster_State


const time = 8.0

var listen_timer : Timer
var arrived : bool
var loudest : float


func _ready() -> void:
	monster = $"../../Willie"
	player = $"../../TestingCharacter"
	nav_mesh = $"../../Nav Regions/BigRoom".navigation_mesh.get_vertices()
	nav_map = $"../../Nav Regions/BigRoom"
	
	listen_timer = Timer.new()
	listen_timer.one_shot = true
	add_child(listen_timer)


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 0.4:
		monster.change_state("searching")
		monster.set_up_state(path)
	else:
		monster.animation_player.play("Injured Run/mixamo_com")
		set_path(player.global_position, RUN_VELOCITY)
	
	##IF SOUND BELOW STRENGTH 6 IS FOUND GO TO THERE BUT ONLY GO TO LOCATION IF ITS THE STRONGEST
	##SOUND HEARD OR ALREADY REACHED THE STRONGEST SPOT


func set_up(loc : Vector3) -> void:
	path = loc
	
	var map = nav_map.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, path)
	
	path = safe_target
	
	loudest = -1.0
	
	


func sound_heard(strength : float, loc : Vector3):
	print("CHANGED")
	if monster.global_position.distance_to(loc) <= 8.0:
		if strength > loudest:
			path = loc
			loudest = strength
