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


const variation : float = 1.0
const search_radius : float = 4.0
const num_search_locations : int = 3

var search_center : Vector3
var search_locs : Array
var searching : bool = false
var curr_index : int


func _ready() -> void:
	monster = $"../../Willie v2"


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 1 and not searching:
		searching = true
		curr_index = 0
	elif searching:
		if monster.global_position.distance_to(search_locs[curr_index]) <= 1:
			curr_index += 1
		
		if curr_index == 3:
			monster.change_state("roaming")
		else:
			monster.animation_player.play("walk-relaxed-loop-378936/walk-relaxed-loop-378936")
			set_path(search_locs[curr_index], WALK_VELOCITY)
	else:
		monster.animation_player.play("chase/b083-runtoblastb")
		set_path(path, RUN_VELOCITY)


func set_up(loc : Vector3) -> void:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * variation
	
	path = Vector3(loc.x - offset.x, loc.y, loc.z - offset.y)
	search_center = path
	
	#print(path.x, " ", path.z)
	
	for i in range(num_search_locations):
		angle = randf() * TAU
		offset = Vector2(cos(angle), sin(angle)) * search_radius
		
		search_locs.push_back(Vector3(search_center.x - offset.x, loc.y, search_center.z - offset.y))
	
	searching = false
