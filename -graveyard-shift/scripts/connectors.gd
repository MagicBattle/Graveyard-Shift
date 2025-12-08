extends NavigationRegion3D

var nav_region : NavigationRegion3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NoiseManager.door_change.connect(rebake)
	nav_region = $"."


func rebake(mesh : String):
	if nav_region.name.to_lower() == mesh:
		#Closing
		if nav_region.get_navigation_layers() == 1:
			nav_region.set_navigation_layer_value(4, true)
			nav_region.set_navigation_layer_value(1, false)
		
		#Opening
		elif nav_region.get_navigation_layers() == 8:
			nav_region.set_navigation_layer_value(4, false)
			nav_region.set_navigation_layer_value(1, true)
