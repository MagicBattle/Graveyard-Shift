class_name HitBox extends Area2D

@export var damage : int = 10

signal Damaged(damage: int)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func TakeDamage(damage: int) -> void:
	print("TakeDamage", damage)
	Damaged.emit(damage)
