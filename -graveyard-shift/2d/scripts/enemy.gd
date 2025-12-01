extends CharacterBody2D

# state machine for monster
enum {
	STATE_ROAM,
	STATE_CHASE,
	STATE_ATTACK
}

var state: int = STATE_ROAM

var move_speed: float = 80.0
var roam_speed: float = 30.0
var roam_radius: float = 80.0

var target: Node2D = null

var health: int = 100
var can_take_damage: bool = true
var player_in_hit_range: bool = false
var facing_dir: String = "down"

var home_position: Vector2
var roam_target: Vector2
var roam_wait_time: float = 0.0

var rng := RandomNumberGenerator.new()

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $healthbar
@onready var damage_cooldown: Timer = $take_damage_cooldown


func _ready() -> void:
	home_position = global_position
	rng.randomize()
	_pick_new_roam_target()


func _physics_process(delta: float) -> void:
	deal_with_damage()
	update_health()

	match state:
		STATE_ROAM:
			_do_roam(delta)
		STATE_CHASE:
			_do_chase()
		STATE_ATTACK:
			_do_attack()

	move_and_slide()

	_handle_roam_collision()


func _do_roam(delta: float) -> void:
	if roam_wait_time > 0.0:
		roam_wait_time -= delta
		velocity = Vector2.ZERO
		_play_idle()
		return

	var to_target: Vector2 = roam_target - global_position
	if to_target.length() < 4.0:
		_pick_new_roam_target()
		roam_wait_time = rng.randf_range(0.4, 1.0)
		velocity = Vector2.ZERO
		_play_idle()
	else:
		var dir := to_target.normalized()
		velocity = dir * roam_speed
		_update_facing_dir(dir)
		anim.play("move_" + facing_dir)


func _do_chase() -> void:
	if target == null:
		state = STATE_ROAM
		return

	if player_in_hit_range:
		state = STATE_ATTACK
		return

	var to_player: Vector2 = target.global_position - global_position
	if to_player.length() < 1.0:
		velocity = Vector2.ZERO
	else:
		var dir := to_player.normalized()
		velocity = dir * move_speed
		_update_facing_dir(dir)

	anim.play("move_" + facing_dir)


func _do_attack() -> void:
	velocity = Vector2.ZERO

	if not player_in_hit_range:
		if target != null:
			state = STATE_CHASE
		else:
			state = STATE_ROAM
		return

	if target != null:
		var to_player: Vector2 = target.global_position - global_position
		if to_player.length() > 0.1:
			_update_facing_dir(to_player.normalized())

	if not anim.animation.begins_with("attack_"):
		anim.play("attack_" + facing_dir)


func _play_idle() -> void:
	anim.play("idle_" + facing_dir)


func _update_facing_dir(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0.0:
			facing_dir = "right"
		else:
			facing_dir = "left"
	else:
		if dir.y > 0.0:
			facing_dir = "down"
		else:
			facing_dir = "up"


func _pick_new_roam_target() -> void:
	var angle := rng.randf_range(0.0, TAU)
	var radius := rng.randf_range(roam_radius * 0.3, roam_radius)
	var offset := Vector2(cos(angle), sin(angle)) * radius
	roam_target = home_position + offset


# temp fix for monsters getting stuck on walls.
func _handle_roam_collision() -> void:
	if state != STATE_ROAM:
		return
	if get_slide_collision_count() == 0:
		return

	var col := get_slide_collision(0)
	var normal := col.get_normal()

	# slide along wall a bit so it doesn't glue
	velocity = velocity.slide(normal) * 0.5
	global_position += normal * 2.0

	# move home slightly away from wall and pick a new roam target
	home_position = global_position + normal * 8.0
	_pick_new_roam_target()
	roam_wait_time = rng.randf_range(0.2, 0.6)
	_play_idle()


func deal_with_damage() -> void:
	if not player_in_hit_range:
		return
	if not can_take_damage:
		return
	if target == null:
		return
	if not target.has_method("is_attack_window_active"):
		return
	if not target.is_attack_window_active():
		return

	health -= 20
	can_take_damage = false
	damage_cooldown.start()
	print("enemy health = ", health)

	if health <= 0:
		queue_free()


func update_health() -> void:
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_hit_range = true
		target = body
		state = STATE_ATTACK


func _on_hit_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_hit_range = false


func _on_detection_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		target = body
		if not player_in_hit_range:
			state = STATE_CHASE


func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		state = STATE_ROAM
		velocity = Vector2.ZERO
		_play_idle()


func _on_AnimatedSprite2D_animation_finished() -> void:
	if anim.animation.begins_with("attack_"):
		if player_in_hit_range:
			state = STATE_ATTACK
		elif target != null:
			state = STATE_CHASE
		else:
			state = STATE_ROAM


func enemy() -> void:
	pass
