extends CharacterBody2D

const SPEED := 100.0

const INPUT_RIGHT := "2d_move_right"
const INPUT_LEFT  := "2d_move_left"
const INPUT_UP    := "2d_move_up"
const INPUT_DOWN  := "2d_move_down"
const INPUT_ATK   := "2d_attack"

var current_dir: String = "down"

var attack_ip: bool = false          # true while attack anim is playing
var attack_window_active: bool = false  # when sword can actually hit

var enemy_inattack_range: bool = false   # enemy inside player hitbox
var enemy_attack_cooldown: bool = true   # stop damage every frame

var health: int = 150
var player_alive: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $attack_cooldown
@onready var deal_attack_timer: Timer = $deal_attack_timer
@onready var regen_timer: Timer = $regen_timer
@onready var healthbar = $healthbar


func _ready() -> void:
	anim.play("idle_down")


func _physics_process(_delta: float) -> void:
	enemy_attack()
	update_health()

	if health <= 0 and player_alive:
		player_alive = false
		health = 0
		print("player has been killed")
		queue_free()
		return

	if attack_ip:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	handle_movement()
	handle_animation()
	move_and_slide()


func handle_movement() -> void:
	velocity = Vector2.ZERO

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

	if Input.is_action_just_pressed(INPUT_ATK) and not attack_ip:
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


func start_attack() -> void:
	if attack_ip:
		return

	attack_ip = true
	attack_window_active = true
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

	deal_attack_timer.start()


func enemy_attack() -> void:
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 10
		enemy_attack_cooldown = false
		attack_cooldown.start()
		print("player health = ", health)


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.begins_with("attack"):
		attack_ip = false


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false


func _on_deal_attack_timer_timeout() -> void:
	deal_attack_timer.stop()
	attack_window_active = false
	# attack_ip ends when the anim finishes


func _on_regen_timer_timeout() -> void:
	if health < 150:
		health += 20
		if health > 150:
			health = 150
		if health < 0:
			health = 0


func update_health() -> void:
	healthbar.value = health
	if health >= 150:
		healthbar.visible = false
	else:
		healthbar.visible = true


# so enemies can do body.has_method("player")
func player() -> void:
	pass


func is_attack_window_active() -> bool:
	return attack_window_active
