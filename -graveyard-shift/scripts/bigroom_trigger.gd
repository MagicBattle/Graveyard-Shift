extends Area3D

@export var delay_seconds: float = 60.0  # 1 minute
var timer_running := false
var completed := false

@onready var dialogue_ui := get_node("/root/World/UI/PlayerScreen")

func _on_body_entered(body: Node3D) -> void:
	if body.name == "TestingCharacter" and not timer_running and not completed:
		timer_running = true
		print("Player is in BigRoom")
		start_timer()

func start_timer() -> void:
	await get_tree().create_timer(delay_seconds).timeout

	# Player must STILL be inside the room after 1 minute!
	if timer_running:
		trigger_dialogue()

func _on_body_exited(body: Node3D) -> void:
	if body.name == "TestingCharacter":
		timer_running = false
		print("Player is out of BigRoom")

func trigger_dialogue() -> void:
	if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
		print("Dialogue printed")
		dialogue_ui.show_dialogue("Hmmm maybe I can find something useful on the desks?", 3.0)
		completed = true
