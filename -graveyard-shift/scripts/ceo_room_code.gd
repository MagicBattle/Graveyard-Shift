extends Node3D

var taken: bool = false

func interact() -> void:
	if taken:
		return
	taken = true
	print("interact with code")
	# Tell tutorial that the player now "knows" the CEO code
	TutorialManager.on_ceo_code_found()

	# You’ll handle showing the code on screen later
	queue_free()
