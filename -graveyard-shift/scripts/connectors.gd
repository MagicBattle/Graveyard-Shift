extends NavigationRegion3D

var nav_region : NavigationRegion3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NoiseManager.door_change.connect(rebake)
	nav_region = $"."


func rebake():
	bake_navigation_mesh(true)
