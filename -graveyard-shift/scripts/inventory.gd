class_name Inventory
extends Node

const MAX_SLOTS: int = 9

signal slot_changed(index: int, item)
signal current_slot_changed(index: int, item)

var slots: Array = []
var current_index: int = 0

func _ready() -> void:
	slots.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		slots[i] = null
		
	current_slot_changed.emit(current_index, slots[current_index])
	
	
func add_item(item) -> bool:
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			slots[i] = item
			slot_changed.emit(i, item)
			return true
	return false
	

func remove_at(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS:
		return

	# Shift everything to the LEFT from index
	for i in range(index, MAX_SLOTS - 1):
		slots[i] = slots[i + 1]
		slot_changed.emit(i, slots[i])

	# Last slot becomes empty
	slots[MAX_SLOTS - 1] = null
	slot_changed.emit(MAX_SLOTS - 1, null)

	# Fix current_index so it still points at a valid slot
	if current_index > index:
		current_index -= 1
	elif current_index >= MAX_SLOTS:
		current_index = MAX_SLOTS - 1

	current_slot_changed.emit(current_index, slots[current_index])
		

func remove_current() -> void:
	remove_at(current_index)
	
func get_current_item():
	return slots[current_index]

func is_slot_empty(index: int) -> bool:
	if index < 0 or index >= MAX_SLOTS:
		return true
	return slots[index] == null
	
	
func select_index(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS:
		return
	if index == current_index:
		return
	current_index = index
	current_slot_changed.emit(current_index, slots[current_index])
	
func select_next(delta: int) -> void:
	"""
	delta += 1 for scroll down, -1 for scroll up
	Wraps around 0...MAX_SLOTS-1
	"""
	var idx := (current_index + delta) % MAX_SLOTS
	if idx < 0:
		idx += MAX_SLOTS
	select_index(idx)
