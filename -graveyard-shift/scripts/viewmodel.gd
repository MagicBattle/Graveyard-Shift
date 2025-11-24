extends Node3D

var current_item_instance: Node3D = null
var Inventory = InventoryManager

func _ready():
	Inventory.current_slot_changed.connect(_update_held_item)

func clear_item():
	if current_item_instance:
		current_item_instance.queue_free()
		current_item_instance = null

func show_item(item: Dictionary) -> void:
	clear_item()
	if item == null or typeof(item) != TYPE_DICTIONARY:
		return
	if not item.has("scene"):
		push_error("Item missing 'scene' key")
		return

	var inst = (item["scene"] as PackedScene).instantiate()

	#  Find MeshInstance3D in the scene
	var mesh: MeshInstance3D = find_first_mesh_instance(inst)

	if mesh:
		# Duplicate only visual part
		current_item_instance = mesh.duplicate()
		
		# Ensure transform is relative to Viewmodel (local space)
		current_item_instance.transform = Transform3D.IDENTITY
		current_item_instance.scale = Vector3(0.2, 0.2, 0.2)
		current_item_instance.position = Vector3(0.25, -0.15, -0.5)  # adjust into view!

		# Add to viewmodel
		add_child(current_item_instance)
	else:
		push_error("No MeshInstance3D found in item scene.")

func _update_held_item(slot_index: int):
	var item = Inventory.get_index_num(slot_index)
	
	# If the slot is empty → clear item
	if item == null:
		clear_item()
		return
		
	show_item(item)

func find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_first_mesh_instance(child)
		if result:
			return result
	return null
