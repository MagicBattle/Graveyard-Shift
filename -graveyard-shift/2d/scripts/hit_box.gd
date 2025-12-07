class_name HitBox extends Area2D

@export var damage : int = 20

signal Damaged(damage: int)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func TakeDamage(damage: int) -> void:
	# mostly unused for sword, kept for compatibility
	print("TakeDamage", damage)
	Damaged.emit(damage)
