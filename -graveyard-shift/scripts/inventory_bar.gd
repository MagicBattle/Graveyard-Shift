extends HBoxContainer

var slots: Array = []
var Inventory = InventoryManager

func _ready():
	# Cache UI slots
	get_slots()
	
	# Always connect inventory signals ONCE
	Inventory.slot_changed.connect(_update_inventory)
	Inventory.current_slot_changed.connect(_highlight_slot)
	
	# Connect state change to control visibility
	GameManager.state_changed.connect(_on_state_changed)

	# Initialize UI right away
	_update_inventory()
	_highlight_slot(Inventory.current_index)

	# Hide until game starts
	visible = GameManager.get_state() == GameManager.State.PLAYING


func get_slots():
	slots = get_children()
	for slot: TextureButton in slots:
		slot.pressed.connect(Inventory.select_index.bind(slot.get_index()))


func _update_inventory(_i=-1, _item=null):
	for slot: TextureButton in slots:
		var item = Inventory.slots[slot.get_index()]

		if item != null and item.has("icon_path"):
			slot.texture_normal = load(item["icon_path"])
		else:
			slot.texture_normal = null


func _highlight_slot(slot_index: int, _item=null):
	for i in range(Inventory.MAX_SLOTS):
		slots[i].modulate = Color(1, 1, 1)
	slots[slot_index].modulate = Color(1.5, 1.5, 1.5)


func _on_state_changed(prev, next):
	visible = (next == GameManager.State.PLAYING)
