##IDEA
##MONSTER HEARS A LOUD SOUND FAR TO MEDIUM DISTANCE AWAY AND INVESTIGATES.
##WALKS TO A POSITION IN THE AREA WHERE THE SOUND WAS HEARD. THE AREA IS SMALLER
##THAN IN THE LOOKING STATE BECAUSE THE SOUND IS LOUDER AND GIVES A BETTER IDEA
##WHERE IT IS. AFTER REACHING THIS POINT 3 RANDOM LOCATIONS ARE CHOSEN WITHIN A
##RADIUS (STILL CHOOSING NUMBER). IF THERE IS ONLY LOW SOUND GO BACK TO ROAMING. 
##IF A MED OR LOUD SOUND IS HEARD GO TO CHASING 

##MAYBE FIND A WAY TO MAKE SURE THAT THE SEARCH LOCATIONS ARE NOT TOO CLOSE TO
##EACH OTHER

##TODO
##1)PROBABLY LOOK INTO A LOOKING AROUND ANITMATION OR INSERT A DELAY BETWEEN
##RUNNING TO THE LOCATION AND SEARCHING THE 3 RANDOMLY GENERATED LOCATIONS
##2)DELAY BETWEEN SWITCHING STATES

class_name Searching
extends Monster_State


const variation : float = 0.3
const search_radius : float = 4.0
const num_search_locations : int = 3

var search_center : Vector3
var search_locs : Array
var distances : Array
var searching : bool = false
var curr_index : int
var prev_search: Vector3


func _ready() -> void:
	monster = $"../../Willie"
	nav_mesh = $"../../BigRoom".navigation_mesh.get_vertices()
	nav_map = $"../../BigRoom"


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 0.45 and not searching:
		searching = true
		curr_index = 0
		prev_search = search_center
	elif searching:
		if (monster.global_position.distance_to(search_locs[curr_index]) <= 0.4 or 
		   monster.global_position.distance_to(prev_search) > distances[curr_index]):
			prev_search = monster.global_position
			curr_index += 1
		
		if curr_index == 3:
			monster.change_state("roaming")
			searching = false
		else:
			monster.animation_player.play("Orc Walk/mixamo_com")
			set_path(search_locs[curr_index], WALK_VELOCITY)
	else:
		monster.animation_player.play("Injured Run/mixamo_com")
		set_path(path, RUN_VELOCITY)


func set_up(loc : Vector3) -> void:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * variation
	
	path = Vector3(loc.x - offset.x, loc.y, loc.z - offset.y)
	
	var map = nav_map.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, path)
	
	path = safe_target
	search_center = safe_target
	
	#print(path.x, " ", path.z)
	
	#MAYBE JUST CHOOSE A RANDOM POINT AND WANDER TO IT THEN ONCE RANDOM DIST AWAY GO TO NEXT POINT
	for i in range(num_search_locations):
		var random_index = randi() % nav_mesh.size()
		
		search_locs.push_back(Vector3(nav_mesh[random_index].x, monster.global_position.y, nav_mesh[random_index].z))
		distances.push_back(randf_range(1.0, search_radius))
	
	searching = false
