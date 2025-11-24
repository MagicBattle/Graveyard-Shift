extends Node3D

var current_item_instance: Node3D = null
 
func _ready():
	Inventory.current_slot_changed.connect(_update_held_item)
 
func clear_item():
	if current_item_instance:
		current_item_instance.queue_free()
		current_item_instance = null
 
func show_item(item_data: ItemData):
	clear_item()
	if item_data and item_data.mesh_scene:
		var inst = item_data.mesh_scene.instantiate()

		# Remove physics-related nodes if any exist
		for child in inst.get_children():
			if child is CollisionShape3D or child is RigidBody3D or child is StaticBody3D:
				child.queue_free()

		# Or: only extract the mesh itself
		var mesh = find_first_mesh_instance(inst)
		if mesh:
			current_item_instance = mesh.duplicate()  # Duplicate only mesh
			current_item_instance.position = Vector3.ZERO
			current_item_instance.rotation = Vector3.ZERO
			current_item_instance.scale = Vector3(0.2, 0.2, 0.2) # adjust size for hand view
			add_child(current_item_instance)
			
func _update_held_item(slot_index: int):
	var item = Inventory.get_index_num(slot_index)
	show_item(item)
				
func find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_first_mesh_instance(child)
		if result:
			return result
	return null
	
	
