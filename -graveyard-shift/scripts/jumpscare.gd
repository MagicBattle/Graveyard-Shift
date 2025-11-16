extends Node3D

@onready var cam: Camera3D = $Camera3D
@onready var anim: AnimationPlayer = $SteamboatWillyMesh/AnimationPlayer


var shaking := true
var shake_intensity := 0.1
var shake_decay := 0.02
var original_cam_transform


func _ready():
	# Keep jumpscare running during pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.process_mode = Node.PROCESS_MODE_ALWAYS

	original_cam_transform = cam.transform

	anim.play("Injured Run/mixamo_com")
	

func _process(delta):
	if shaking:
		_camera_shake(delta)


func _camera_shake(delta):
	if shake_intensity <= 0:
		shaking = false
		cam.transform = original_cam_transform
		get_tree().paused = false
		# Set Mouse Visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")
		return

	var offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

	cam.transform.origin = original_cam_transform.origin + offset

	shake_intensity -= shake_decay * delta
