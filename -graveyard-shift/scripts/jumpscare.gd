extends Node3D

@onready var cam: Camera3D = $Camera3D
@onready var anim: AnimationPlayer = $SteamboatWillyMesh/AnimationPlayer


var shaking := true
var shake_intensity := 0.1
var shake_decay := 0.1
var original_cam_transform


func _ready():
	# Keep jumpscare running during pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.process_mode = Node.PROCESS_MODE_ALWAYS

	original_cam_transform = cam.transform
	
	# Plays Jumpscare animation (CHANGE UNTIL WE HAVE THE ANIMATION READY)
	anim.play("Jump Over/mixamo_com")
	

func _process(delta):
	if shaking:
		_camera_shake(delta)


func _camera_shake(delta):
	# Stop shaking and return to menu
	if shake_intensity <= 0:
		shaking = false
		cam.transform = original_cam_transform
		# Set Mouse Visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GameManager.show_death_screen()
		return
	
	# Generate random offset of shake intensity
	var offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	# Apply offset to camera
	cam.transform.origin = original_cam_transform.origin + offset

	# Decrease shake intensity
	shake_intensity -= shake_decay * delta
