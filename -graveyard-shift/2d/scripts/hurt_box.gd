class_name HurtBox extends Area2D

@export var damage : int = 1

func _ready() -> void:
	area_entered.connect(AreaEntered)

func _process(delta: float) -> void:
	pass

func AreaEntered(a: Area2D) -> void:
	# if player's HitBox hit us, call TakeDamage on the enemy (parent)
	if a is HitBox:
		if get_parent().has_method("TakeDamage"):
			get_parent().TakeDamage(a.damage)
