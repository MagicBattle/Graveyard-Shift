extends RigidBody3D

@export var mc : CharacterBody3D
@export var weight : float = 50


@onready var aoe := $Area3D


var pushing : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aoe.body_entered.connect(_on_body_entered)
	aoe.body_exited.connect(_on_body_exited)
	

func _on_body_entered(body):
	if body == mc:
		pushing = true

func _on_body_exited(body):
	if body == mc:
		pushing = false
		
func _physics_process(delta):
	if pushing:
		var strength = ((mc.weight * delta) - (weight * delta))
		if strength > 0:
			var impulse = mc.direction * ((mc.weight * delta) - (weight * delta))
			apply_impulse(impulse)
		if strength <= 0 :
			var impulse = mc.direction * delta * 10
			apply_impulse(impulse)
		

		
	
