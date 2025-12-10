extends Node3D

var taken: bool = false

func interact() -> void:
	if taken:
		return
	taken = true
	# Tell tutorial that the player now "knows" the CEO code
	TutorialManager.on_ceo_code_found()
	TutorialManager.on_code_picked_up()
	
	queue_free()
