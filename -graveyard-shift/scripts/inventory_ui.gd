extends HBoxContainer


var slots: Array

func _ready():
	get_slots() 
	GameManager.state_changed.connect(_on_state_changed) 
	if GameManager.get_state() == GameManager.State.PLAYING: 
		_connect_inventory_signals()


func _connect_inventory_signals():
	if !Inventory.slot_changed.is_connected(_update_inventory):
		Inventory.slot_changed.connect(_update_inventory) 
	if !Inventory.current_slot_changed.is_connected(_highlight_slot):
		Inventory.current_slot_changed.connect(_highlight_slot) 
	_update_inventory()
	
	
func _on_state_changed(prev, next):
	if next == GameManager.State.PLAYING:
		self.visible = true 
		_connect_inventory_signals() 
	else: 
		self.visible = false

func get_slots():
	slots = get_children()
	for slot: TextureButton in slots:
		slot.pressed.connect(Inventory.select_index.bind(slot.get_index()))
	
	
func _update_inventory():
	for slot: TextureButton in slots:
		var item = Inventory.slots[slot.get_index()]

		if item != null and item.has("icon_path"):
			slot.texture_normal = load(item["icon_path"])
		else:
			slot.texture_normal = null
	
	#print("UI Updated → ", Inventory.slots)
			

func _highlight_slot(slot_index: int):
	for i in range(Inventory.MAX_SLOTS):
		slots[i].modulate = Color(1, 1, 1)
	slots[slot_index].modulate = Color(1.5, 1.5, 1.5)	
