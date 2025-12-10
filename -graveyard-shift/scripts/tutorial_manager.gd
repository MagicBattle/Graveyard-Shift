extends Node

@export var monster_node: Node3D
var thunder_player: AudioStreamPlayer3D = null

enum Step {
	INACTIVE,
	INTRO_LOOK,
	PICK_PAPER,
	THROW_PAPER,
	GO_TO_CEO,
	PHONE_CALL,
	FIND_CEO_CODE,
	PLAY_TV,
	HIDE_IN_CEO,
	ESCAPE,
	DONE
}

var step: Step = Step.INACTIVE
var active: bool = false

var player: CharacterBody3D
var objective_ui
var controls_ui
var paper_ball_slot_change: bool
# how much the player has "looked around"
var _look_amount := 0.0
const LOOK_THRESHOLD := 500.0  # tweak later if needed

var ui_locked_by_tutorial: bool = false
var _code_picked_early: bool = false

var phone_node: Node3D = null
var phone_call_done: bool = false

var ceo_door: Node = null   # door.gd instance
var has_placed_boss_file = false
var monster_look_target: Node3D
var door_look_target: Node3D
var room_look: Node3D
var player_look: Node3D
var monster: Node3D = null
var monster_distraction_target: Node3D = null
var monster_scene: PackedScene = null

var has_ceo_door_code: bool = false
var has_exit_door_code: bool = false

var tv_started: bool = false
var tv_finished: bool = false

var tv_node: Node3D = null

var dialogue_ui: Control = null

var paper_scored: bool = false

var codes_ui: Control = null

func set_thunder(node: AudioStreamPlayer3D) -> void:
	thunder_player = node

func set_codes_ui(ui: Control) -> void:
	codes_ui = ui


func on_trash_scored() -> void:
	# only matters during the THROW_PAPER step
	if not active:
		return
	if step != Step.THROW_PAPER:
		return
	paper_scored = true


func set_dialogue_ui(ui: Control) -> void:
	dialogue_ui = ui

func _say(text: String, duration: float = 3.0) -> void:
	if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
		dialogue_ui.show_dialogue(text, duration)


func set_tv(tv: Node3D) -> void:
	tv_node = tv

func set_phone(phone: Node3D) -> void:
	phone_node = phone

func on_ceo_code_found() -> void:
	if codes_ui and codes_ui.has_method("show_code"):
		codes_ui.show_code(0, "1643")
	has_ceo_door_code = true

func on_exit_code_found() -> void:
	if codes_ui and codes_ui.has_method("show_code"):
		codes_ui.show_code(1, "8975")
	has_exit_door_code = true

func can_use_ceo_door() -> bool:
	return has_ceo_door_code and phone_call_done

func can_use_exit_door() -> bool:
	return has_exit_door_code

func on_exit_door_allow() -> void:
	_say("It's locked? Do I use the code I got from watching the video?")


func on_tv_started() -> void:
	tv_started = true
	if controls_ui:
		controls_ui.show_controls_timed("Enter: Skip video", 4.0)

func on_tv_finished() -> void:
	tv_finished = true
	# Change objective to Playrooms
	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Complete your new task")
	_say("OK, task should be simple. I got a code as well. Wonder what it is for.", 4.0)

func _ready() -> void:
	if monster_node:
		monster = monster_node

func set_monster_scene(scene: PackedScene) -> void:
	monster_scene = scene


func set_monster(m: Node3D) -> void:
	monster = m

func set_monster_distraction_target(t: Node3D) -> void:
	monster_distraction_target = t


func set_look_targets(monster_target: Node3D, door_target: Node3D, room_target: Node3D, player_look_target: Node3D) -> void:
	monster_look_target = monster_target
	door_look_target = door_target
	room_look = room_target
	player_look = player_look_target

func set_ceo_door(door: Node) -> void:
	ceo_door = door


func _show_tutorial_controls(text: String):
	ui_locked_by_tutorial = true
	controls_ui.show_controls(text)
func _hide_tutorial_controls():
	controls_ui.hide_controls()
	ui_locked_by_tutorial = false



func begin(p: CharacterBody3D, obj_ui, ctrl_ui) -> void:
	player = p
	objective_ui = obj_ui
	controls_ui = ctrl_ui
	active = true
	step = Step.INTRO_LOOK
	_code_picked_early = false
	has_placed_boss_file = false
	# Put the game into tutorial phase
	GameManager.set_phase(GameManager.Phase.TUTORIAL)
	
	if player and player.has_method("set_tutorial_movement_locked"):
		player.set_tutorial_movement_locked(true)

	_start_intro_look()

# Tell player to look around (Teaches camera movement)
func _start_intro_look() -> void:
	if not active:
		return

	step = Step.INTRO_LOOK
	_look_amount = 0.0

	# Intro line
	_say("Finally! Done with the report! Now I can go home. I should tidy up my desk though.", 4.0)

	if objective_ui:
		objective_ui.set_objective("Look around your desk.")
	if controls_ui:
		_show_tutorial_controls("Move mouse to look around")

# Called from player to check if player has looked enough
func on_player_looked(delta_amount: float) -> void:
	# Ignore if not in this step
	if not active or step != Step.INTRO_LOOK:
		return

	_look_amount += delta_amount

	# When the player has moved the camera enough, complete this step
	if _look_amount >= LOOK_THRESHOLD:
		_complete_intro_look()

# Go to pick up paper ball step
func _complete_intro_look() -> void:
	if not active or step != Step.INTRO_LOOK:
		return

	# Mark this objective as done
	if objective_ui:
		objective_ui.mark_completed()

	if controls_ui:
		_hide_tutorial_controls()
	
	
	_start_pick_paper()

# Start pick up paper objective (Teaches interact)
func _start_pick_paper() -> void:
	if not active:
		return
	step = Step.PICK_PAPER
	paper_ball_slot_change = true
	if objective_ui:
		objective_ui.set_objective("Pick up the paper ball on your desk.")
	if controls_ui:
		_show_tutorial_controls("F: Interact to pick up")

# Start once player has picked up the ball
func _start_throw_paper() -> void:
	if not active:
		return
	step = Step.THROW_PAPER

	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Throw the paper ball into the trash can.")
	if controls_ui:
		_show_tutorial_controls("1–9 or scroll wheel to select items")
	paper_ball_slot_change = false


# Show throw controls after player selects slot
func on_throwable_slot_selected() -> void:
	if not active or step != Step.THROW_PAPER:
		return
	if controls_ui:
		_show_tutorial_controls("LMB: Throw\nHold: To Charge")


func on_paper_ball_picked() -> void:
	if not active or step != Step.PICK_PAPER:
		return
	_start_throw_paper()

# Show movement controls once paper ball is thrown
func on_paper_ball_thrown() -> void:
	if not active or step != Step.THROW_PAPER:
		return
	
	# Unlock movement now that they've thrown once
	if player and player.has_method("set_tutorial_movement_locked"):
		player.set_tutorial_movement_locked(false)
	
	if objective_ui:
		objective_ui.mark_completed()
	
	if controls_ui:
		controls_ui.show_controls_timed("WASD: To Move", 5)
	
	# Decide which dialogue AFTER physics/trigger had time to fire
	_decide_trash_result()

# Check if player got paper  ball in trash or not
func _decide_trash_result() -> void:
	# small delay so TrashTrigger can emit its signal
	await get_tree().create_timer(1, false).timeout
	
	if not active or step != Step.THROW_PAPER:
		return
	
	if paper_scored:
		_say("Nice.", 2.0)
	else:
		_say("...Good enough, Janitor can get it.", 3.0)
	
	paper_scored = false
	await get_tree().create_timer(7.0, false).timeout
	_start_phone_step()


# Deny access until phone call and code pickup
func on_ceo_door_denied() -> void:
	if not active:
		return
	if not has_ceo_door_code:
		_say("I don't have the code yet.", 2.5)
	elif not TutorialManager.phone_call_done:
		_say("I should listen to the call. It could be important.", 3.0)

# Deny until cutscene
func on_exit_door_denied() -> void:
	if not active:
		return

	match step:
		Step.PHONE_CALL:
			_say("I should listen to the phone call. It could be important.", 3.0)
		Step.GO_TO_CEO:
			_say("I should go to the CEO's room.", 3.0)
		_:
			# fallback if something weird happens
			_say("I should finish this task first.", 2.5)

# Start phone call
func _start_phone_step() -> void:
	if not active:
		return
	if phone_node and phone_node.has_method("start_ringing"):
		phone_node.start_ringing()
	step = Step.PHONE_CALL
	phone_call_done = false

	if objective_ui:
		objective_ui.set_objective("Pick up the phone.")
	if controls_ui:
		_show_tutorial_controls("F: Interact")
	
	_say("Who's calling at this time?", 3.0)


func on_phone_started() -> void:
	if controls_ui:
		controls_ui.show_controls_timed("Enter: Skip Phone Call", 4.0)


func on_phone_finished() -> void:
	if not active:
		return

	phone_call_done = true
	step = Step.FIND_CEO_CODE

	if objective_ui:
		objective_ui.mark_completed()
	if controls_ui:
		_hide_tutorial_controls()
		
	get_code()

# Check if code was picked up before, change dialogue and objective accordingly
func get_code() -> void:
	if not active:
		return
	if _code_picked_early:
		_code_picked_early = false
		_say("Hmmm ok, one more task. The code to CEO's room...is that what I found earlier?", 4.0)
		_unlock_ceo_door()
		return
	step = Step.FIND_CEO_CODE
	
	if objective_ui:
		objective_ui.set_objective("Get the code from Michael's desk.")
		
	_say("Hmmm ok, one more task. Now, Michael's desk... I think that was the one in the corner?", 4.0)
	

func on_code_picked_up() -> void:
	if not active:
		return
	
	if step == Step.FIND_CEO_CODE:
		if objective_ui:
			objective_ui.mark_completed()
		
			
		_unlock_ceo_door()
		return
	_say("Is this a code?")
	_code_picked_early = true

# Display Run controls(once code is picked up) and then later how to interact with doors
func _unlock_ceo_door():
	if not active:
		return
	step = Step.GO_TO_CEO
	
	if objective_ui:
		objective_ui.set_objective("Use the code to unlock CEO's office")
	if controls_ui:
			_show_tutorial_controls("Shift: Run")
			await get_tree().create_timer(4.0).timeout
			_show_tutorial_controls("F: Interact with Doors")


func on_ceo_door_unlocked() -> void:
	if not active or step != Step.GO_TO_CEO:
		return
	codes_ui.clear_code(0)
	if objective_ui:
		objective_ui.mark_completed()
	
	_start_watch_tv()

# Watch TV
func _start_watch_tv() -> void:
	if not active:
		return
	step = Step.PLAY_TV

	if objective_ui:
		objective_ui.set_objective("Watch the TV for your new task.")
	if controls_ui:
		_hide_tutorial_controls()

# Start cutscene when player leaves Ceo Room
func on_player_left_ceo_room() -> void:
	if not active:
		return
	if step != Step.PLAY_TV:
		return

	# If TV not finished yet, block the cutscene and pause the video
	if not tv_finished:
		# Pause TV if it’s currently playing
		if tv_node and tv_node.has_method("pause_video"):
			tv_node.pause_video()
		# Do NOT start monster cutscene yet
		return

	step = Step.HIDE_IN_CEO

	await _start_monster_intro_cutscene()



func _start_monster_intro_cutscene() -> void:
	if not active or player == null:
		return
	
	# Spawn monster
	if monster == null:
		if monster_scene != null and monster_look_target != null:
			monster = monster_scene.instantiate()
			var parent := player.get_parent()
			parent.add_child(monster)
			monster.global_position = monster_look_target.global_position
			monster.look_at(door_look_target.global_position)
	
	# Lock input/UI during cutscene
	player.set_tutorial_movement_locked(true)
	player.set_ui_locked(true)
	
	if player and player.has_method("set_hud_visible"):
		player.set_hud_visible(false)
	
	player.force_look_at_flat(player_look.global_position)
	
	# Walk a bit forward (towards hallway / right etc.)
	var forward: Vector3 = -player.head.global_transform.basis.z
	player.begin_cutscene_motion(forward, 2.0, 1.0)
	await get_tree().create_timer(1.0, false).timeout
	
	if monster and monster.has_method("play_growl_intro"):
		monster.play_growl_intro()
	
	_say("Huh?", 1.0)
	
	# 2) Look toward monster
	if monster_look_target:
		player.smooth_look_at_flat(monster_look_target.global_position, 0.5)
		await get_tree().create_timer(1.5, false).timeout  # wait for the turn to finish
	else:
		var look_point: Vector3 = player.head.global_transform.origin + forward * 5.0
		player.force_look_at_flat(look_point)
	
	# Player spots Willie
	_say("What is that!", 2.0)
	await get_tree().create_timer(3.0).timeout
	# Monster first growl (intro)
	if monster and monster.has_method("play_growl_intro"):
		monster.play_growl_intro()
	await get_tree().create_timer(1.5, false).timeout
	_say("What the...!", 2.0)
	await get_tree().create_timer(1.0, false).timeout
	
	player.smooth_look_at_flat(room_look.global_position, 0.4)
	await get_tree().create_timer(0.4, false).timeout
	
	# Walk back into CEO room
	var into_room: Vector3 = -player.head.global_transform.basis.z
	player.begin_cutscene_motion(into_room, 2.5, 1.2)
	await get_tree().create_timer(1.2, false).timeout

	# Close + lock CEO door
	if ceo_door:
		if ceo_door.has_method("close"):
			ceo_door.close()
		if ceo_door.has_method("lock"):
			ceo_door.lock()
		if ceo_door.has_method("set_tutorial_locked"):
			ceo_door.set_tutorial_locked(true)
	
	if player and player.has_method("set_hud_visible"):
		player.set_hud_visible(true)
		
	# Let player move again (but they’re “locked in”)
	player.set_tutorial_movement_locked(false)
	player.set_ui_locked(false)
	
	if objective_ui:
		objective_ui.set_objective("Hide in the CEO's office.")
	if controls_ui:
		controls_ui.show_controls_timed("C: Crouch to stay low", 8.0)

	# Start second part (monster at door)
	await _start_monster_door_sequence()

# Show crouch control and then later tilt and walk slowly
func _start_monster_door_sequence() -> void:
	if not active or player == null:
		return
	if monster == null or ceo_door == null:
		return

	# Give player a second or two to actually crouch
	await get_tree().create_timer(2.0, false).timeout

	# MONSTER WALKS TOWARDS CEO DOOR
	if monster.has_method("start_tutorial_walk_to"):
		monster.start_tutorial_walk_to(door_look_target.global_position)
	
	_say("What do I do? What do I do?!", 3.0)
	
	# Let the monster "arrive" at the door
	await get_tree().create_timer(7.5, false).timeout
	
	if monster and door_look_target and monster.has_method("stop_tutorial_and_face"):
		monster.stop_tutorial_and_face(room_look.global_position)
	# LOCK PLAYER VIEW + OPEN DOOR
	player.set_tutorial_movement_locked(true)
	player.set_ui_locked(true)

	# Look at the door
	if door_look_target:
		player.smooth_look_at_flat(door_look_target.global_position, 1)
	if monster and monster.has_method("play_growl_at_door"):
		monster.play_growl_at_door()

	# Allow the door to operate again
	# then open it (as if monster opened it).
	if ceo_door.has_method("set_tutorial_locked"):
		ceo_door.set_tutorial_locked(false)

	if ceo_door.has_method("unlock_and_open"):
		ceo_door.unlock_and_open()
	else:
		# Fallback: manually clear locked, then open
		if ceo_door.has_method("open"):
			ceo_door.locked = false
			ceo_door.open()
	
	await get_tree().create_timer(2.0).timeout
	
	# Play thunder
	if thunder_player:
		thunder_player.play()
	# Small suspense pause with door open + monster there
	_say("...", 3.0)
	await get_tree().create_timer(2.0, false).timeout
	
	# DISTRACTION SOUND FAR AWAY
	if monster_distraction_target:
		var p := monster_distraction_target.global_position
		if monster.has_method("play_growl_run"):
			monster.play_growl_run()
		if monster.has_method("play_footsteps_run"):
			monster.play_footsteps_run()
		if monster.has_method("go_to_distraction"):
			monster.go_to_distraction(p)

	# Give monster a bit of time to "walk away"
	await get_tree().create_timer(5.0, false).timeout
	
	if monster and is_instance_valid(monster):
		monster.queue_free()
		monster = null
		
	# RETURN CONTROL TO PLAYER – TUTORIAL ESCAPE PHASE
	player.set_tutorial_movement_locked(false)
	player.set_ui_locked(false)

	step = Step.ESCAPE
	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Find a way out")
	
	_say("Was that Willie? Is this part of the task?", 4.0)
	if controls_ui:
		controls_ui.show_controls_timed("Q or E: To look around corners", 3.0)
		await get_tree().create_timer(8.0, false).timeout
	
	_say("Is it gone? I should stay cautious.", 2.0)
	_say("Thankfully, the loud noise distracted...that thing. I think he is sensitive to sound.", 2.0)
	await get_tree().create_timer(4.0).timeout
	controls_ui.show_controls_timed("CTRL: Walk slowly", 3.0)
	
func clear_exit_code() -> void:
	codes_ui.clear_code(1)
	
