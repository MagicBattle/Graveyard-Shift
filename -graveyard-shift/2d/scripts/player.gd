extends CharacterBody2D

const SPEED := 100.0

const INPUT_RIGHT := "2d_move_right"
const INPUT_LEFT  := "2d_move_left"
const INPUT_UP    := "2d_move_up"
const INPUT_DOWN  := "2d_move_down"
const INPUT_ATK   := "2d_attack"

var current_dir: String = "down"
var attack_ip: bool = false          # true while an attack animation is playing
var can_attack: bool = true          # false while on cooldown

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $attack_cooldown


func _ready() -> void:
	anim.play("idle_down")


func _physics_process(_delta: float) -> void:
	# While attacking, ignore movement input and stay still
	if attack_ip:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	handle_movement()
	handle_animation()
	move_and_slide()


func handle_movement() -> void:
	velocity = Vector2.ZERO

	# 4-way movement (no diagonals because that's extra work)
	if Input.is_action_pressed(INPUT_RIGHT):
		velocity.x = SPEED
		current_dir = "right"
	elif Input.is_action_pressed(INPUT_LEFT):
		velocity.x = -SPEED
		current_dir = "left"
	elif Input.is_action_pressed(INPUT_DOWN):
		velocity.y = SPEED
		current_dir = "down"
	elif Input.is_action_pressed(INPUT_UP):
		velocity.y = -SPEED
		current_dir = "up"

	if Input.is_action_just_pressed(INPUT_ATK) and can_attack:
		start_attack()


func handle_animation() -> void:
	if attack_ip:
		return

	var moving := velocity.length() > 0.0

	if current_dir == "right":
		if moving:
			anim.play("run_right")
		else:
			anim.play("idle_right")

	elif current_dir == "left":
		if moving:
			anim.play("run_left")
		else:
			anim.play("idle_left")

	elif current_dir == "down":
		if moving:
			anim.play("run_down")
		else:
			anim.play("idle_down")

	elif current_dir == "up":
		if moving:
			anim.play("run_up")
		else:
			anim.play("idle_up")

	else:
		anim.play("idle_down") 


# stopped movement during attack, but could change depending on game feel
func start_attack() -> void:
	if attack_ip or not can_attack:
		return

	attack_ip = true
	can_attack = false
	velocity = Vector2.ZERO  

	if current_dir == "right":
		anim.play("attack_right")
	elif current_dir == "left":
		anim.play("attack_left")
	elif current_dir == "down":
		anim.play("attack_down")
	elif current_dir == "up":
		anim.play("attack_up")
	else:
		anim.play("attack_down")

	attack_cooldown.start()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.begins_with("attack"):
		attack_ip = false


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
