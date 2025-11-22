extends HBoxContainer


var slots: Array

func _ready():
	get_slots()
	Inventory.slot_changed.connect(_update_inventory)
	Inventory.current_slot_changed.connect(_highlight_slot)
	_update_inventory()

func get_slots():
	slots = get_children()
	for slot: TextureButton in slots:
		slot.pressed.connect(Inventory.select_index.bind(slot.get_index()))
	
	
func _update_inventory():
	if GameManager.get_state() != GameManager.State.PLAYING:
		self.hide()
		return  # Ignore inventory updates until gameplay begins
	
	self.show()	
	for slot: TextureButton in slots:
		var item = Inventory.slots[slot.get_index()]
		if item is ItemData:
			slot.texture_normal = item.icon
		else:
			slot.texture_normal = null
			

func _highlight_slot(slot_index: int):
	for i in range(Inventory.MAX_SLOTS):
		slots[i].modulate = Color(1, 1, 1)
	slots[slot_index].modulate = Color(1.5, 1.5, 1.5)	
