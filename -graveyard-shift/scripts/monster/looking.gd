##TODO
##1) PROBABLY LOOK INTO A TIMER TO DELAY THE SWITCH BETWEEN LOOKING AND ROAMING
##RIGHT NOW THE SWITCH IS KINDA SUDDEN
##2) IF POSSIBLE MAYBE ADD LOOKING AROUND ANIMATION INBETWEEN SWITCHING STATES

class_name Looking
extends Monster_State


const variation : float = 2.0
 

func _ready() -> void:
	monster = $"../../Willie v2"


func action(_delta:float):
	if monster.global_position.distance_to(path) <= 1:
		monster.change_state("roaming")
	else:
		monster.animation_player.play("walk-relaxed-loop-378936/walk-relaxed-loop-378936")
		set_path(path, WALK_VELOCITY)


func set_up(loc : Vector3) -> void:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * variation
	
	path = Vector3(loc.x - offset.x, loc.y, loc.z - offset.y)
	
	#print(path.x, " ", path.z)
