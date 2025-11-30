extends Node

enum Step {
	INACTIVE,
	INTRO_LOOK,
	PICK_PAPER,
	THROW_PAPER,
	PICK_FILE,      # next step after THROW_PAPER
	GO_TO_CEO,
	PLACE_FILE,
	HIDE_IN_CEO,
	ESCAPE,
	DONE
	# (we'll add more steps later)
}

var step: Step = Step.INACTIVE
var active: bool = false

var player: CharacterBody3D
var objective_ui
var controls_ui

# how much the player has "looked around"
var _look_amount := 0.0
const LOOK_THRESHOLD := 500.0  # tweak later if needed

var ui_locked_by_tutorial: bool = false
var _file_picked_early: bool = false

var ceo_door: Node = null   # door.gd instance

var monster_look_target: Node3D
var door_look_target: Node3D
var monster: Node3D = null
var monster_distraction_target: Node3D = null
var monster_scene: PackedScene = null

func set_monster_scene(scene: PackedScene) -> void:
	monster_scene = scene


func set_monster(m: Node3D) -> void:
	monster = m

func set_monster_distraction_target(t: Node3D) -> void:
	monster_distraction_target = t


func set_look_targets(monster_target: Node3D, door_target: Node3D) -> void:
	monster_look_target = monster_target
	door_look_target = door_target

func set_ceo_door(door: Node) -> void:
	ceo_door = door


func _show_tutorial_controls(text: String):
	controls_ui.show_controls(text)
	ui_locked_by_tutorial = true

func _hide_tutorial_controls():
	controls_ui.hide_controls()
	ui_locked_by_tutorial = false



func begin(p: CharacterBody3D, obj_ui, ctrl_ui) -> void:
	player = p
	objective_ui = obj_ui
	controls_ui = ctrl_ui

	active = true
	step = Step.INTRO_LOOK
	_file_picked_early = false

	# Put the game into tutorial phase
	GameManager.set_phase(GameManager.Phase.TUTORIAL)
	
	if player and player.has_method("set_tutorial_movement_locked"):
		player.set_tutorial_movement_locked(true)

	_start_intro_look()
	
func _start_intro_look() -> void:
	if not active:
		return

	step = Step.INTRO_LOOK
	_look_amount = 0.0

	if objective_ui:
		objective_ui.set_objective("Look around your desk.")
	if controls_ui:
		_show_tutorial_controls("Move mouse to look around")


func on_player_looked(delta_amount: float) -> void:
	# Ignore if not in this step
	if not active or step != Step.INTRO_LOOK:
		return

	_look_amount += delta_amount

	# When the player has moved the camera enough, complete this step
	if _look_amount >= LOOK_THRESHOLD:
		_complete_intro_look()


func _complete_intro_look() -> void:
	if not active or step != Step.INTRO_LOOK:
		return

	# Mark this objective as done
	if objective_ui:
		objective_ui.mark_completed()

	if controls_ui:
		_hide_tutorial_controls()
	
	print("Tutorial: intro look step completed")
	
	# For now we just stop here - step done.
	# Later we will continue to "pick up paper ball" from here.
	_start_pick_paper()  # or keep it INTRO_LOOK until we add next step

	
func _start_pick_paper() -> void:
	if not active:
		return
	step = Step.PICK_PAPER

	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Pick up the paper ball on your desk.")
	if controls_ui:
		_show_tutorial_controls("F: Interact to pick up")

func _start_throw_paper() -> void:
	if not active:
		return
	step = Step.THROW_PAPER

	# Lock movement: stand still and throw from here

	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Throw the paper ball into the trash can.")
	if controls_ui:
		_show_tutorial_controls("LMB: Throw\nHold: To Charge")
		
func on_paper_ball_picked() -> void:
	if not active or step != Step.PICK_PAPER:
		return
	_start_throw_paper()

func on_paper_ball_thrown() -> void:
	if not active or step != Step.THROW_PAPER:
		return

	# Unlock movement now that they've thrown once
	if player and player.has_method("set_tutorial_movement_locked"):
		player.set_tutorial_movement_locked(false)

	if objective_ui:
		objective_ui.mark_completed()
	if controls_ui:
		_hide_tutorial_controls()
	
	if controls_ui:
		controls_ui.show_controls_timed("WASD: To Move", 3)
		
	_start_pick_file()
	# For now, after throw step, we just stop at INACTIVE.
	# Next we will go to "pick up file" in the following step.
	#step = Step.MOVE_UNLOCKED
	print("Tutorial: throw paper step completed")
	
func _start_pick_file() -> void:
	if not active:
		return
	
	if _file_picked_early:
		_file_picked_early = false
		_start_go_to_ceo()
		return
	step = Step.PICK_FILE
	
	

	if objective_ui:
		objective_ui.set_objective("Pick up the file from your desk.")
	if controls_ui:
		_show_tutorial_controls("F: Interact to pick up")

func on_boss_file_picked() -> void:
	if not active:
		return

	# Normal path: we are currently in the PICK_FILE step
	if step == Step.PICK_FILE:
		if objective_ui:
			objective_ui.mark_completed()
		if controls_ui:
			_hide_tutorial_controls()

		_start_go_to_ceo()
		return

	# Early pickup: we haven't reached the PICK_FILE step yet.
	# Just remember it happened; when we later call _start_pick_file(),
	# we'll skip that step and go to the CEO objective.
	_file_picked_early = true


func _start_go_to_ceo() -> void:
	if not active:
		return
	step = Step.GO_TO_CEO

	if objective_ui:
		objective_ui.set_objective("Take the file to the CEO's office.")

func on_ceo_door_unlocked() -> void:
	if not active or step != Step.GO_TO_CEO:
		return

	if objective_ui:
		objective_ui.mark_completed()
	if controls_ui:
		_hide_tutorial_controls()

	_start_place_file()


func _start_place_file() -> void:
	if not active:
		return
	step = Step.PLACE_FILE

	if objective_ui:
		objective_ui.set_objective("Place the file on the CEO's desk.")
	if controls_ui:
		_show_tutorial_controls("Look at the desk and press F to place the file.")


func on_boss_file_placed() -> void:
	if not active or step != Step.PLACE_FILE:
		return

	# Finish the "place file" objective
	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Leave the CEO's office.")

	# Hide any controls hints for now
	if controls_ui:
		_hide_tutorial_controls()

	print("Tutorial: file placed – waiting for player to leave CEO room.")

func on_player_left_ceo_room() -> void:
	if not active or step != Step.PLACE_FILE:
		return

	print("Tutorial: player left CEO room – starting monster intro cutscene.")
	_start_monster_intro_cutscene()

func _start_monster_intro_cutscene() -> void:
	if not active or player == null:
		return
	
	if monster == null:
		if monster_scene != null and monster_look_target != null:
			monster = monster_scene.instantiate()
			# add next to player so "../TestingCharacter" is still a valid path
			var parent := player.get_parent()
			parent.add_child(monster)
			monster.global_position = monster_look_target.global_position
			print("Tutorial: spawned monster at MonsterLookAt.")
		else:
			print("Tutorial: monster_scene or monster_look_target not set, cannot spawn monster.")
	
	# Lock input/UI during cutscene
	player.set_tutorial_movement_locked(true)
	player.set_ui_locked(true)

	# 1) Walk a bit forward (towards hallway)
	var forward: Vector3 = -player.head.global_transform.basis.z
	player.begin_cutscene_motion(forward, 2.0, 1.0)
	await get_tree().create_timer(1.0).timeout

	# 2) Look toward monster
	if monster_look_target:
		player.force_look_at_flat(monster_look_target.global_position)
	else:
		var look_point: Vector3 = player.head.global_transform.origin + forward * 5.0
		player.force_look_at_flat(look_point)

	await get_tree().create_timer(1.0).timeout

	# 3) Walk back into CEO room
	var right: Vector3 = player.head.global_transform.basis.x
	player.begin_cutscene_motion(right, 2.5, 1.2)
	await get_tree().create_timer(1.2).timeout

	# 🔒 Now that the player is back inside, close + lock the CEO door
	if ceo_door:
		if ceo_door.has_method("close"):
			ceo_door.close()
		if ceo_door.has_method("lock"):
			ceo_door.lock()
		if ceo_door.has_method("set_tutorial_locked"):
			ceo_door.set_tutorial_locked(true)

	# End of this cutscene – player can move again,
	# but the door is locked and unusable.
	player.set_tutorial_movement_locked(false)
	player.set_ui_locked(false)

	step = Step.HIDE_IN_CEO

	if objective_ui:
		objective_ui.set_objective("Hide in the CEO's office.")
	if controls_ui:
		_show_tutorial_controls("CTRL: Crouch to stay low")
	
	_start_monster_door_sequence()
	
func _start_monster_door_sequence() -> void:
	if not active or player == null:
		return
	if monster == null or ceo_door == null:
		print("Tutorial: monster or CEO door not set – skipping door sequence.")
		return

	# Give player a second or two to actually crouch
	await get_tree().create_timer(2.0).timeout

	# 1) MONSTER WALKS TOWARDS CEO DOOR
	#    You will implement start_tutorial_walk_to() in the monster script.
	if monster.has_method("start_tutorial_walk_to"):
		monster.start_tutorial_walk_to(ceo_door.global_transform.origin)
	else:
		print("Monster has no start_tutorial_walk_to, just spawning it near door.")

	# Let the monster "arrive" at the door (tweak this time to match its speed)
	await get_tree().create_timer(3.0).timeout

	# 2) LOCK PLAYER VIEW + OPEN DOOR
	player.set_tutorial_movement_locked(true)
	player.set_ui_locked(true)

	# Look at the door
	if door_look_target:
		player.force_look_at_flat(door_look_target.global_position)

	# Allow the door to operate again (no more tutorial lock),
	# then open it (as if monster opened it).
	# Allow the door to operate again (no more tutorial lock),
# then open it (as if monster opened it).
	if ceo_door.has_method("set_tutorial_locked"):
		ceo_door.set_tutorial_locked(false)

# Use the helper if it exists
	if ceo_door.has_method("unlock_and_open"):
		ceo_door.unlock_and_open()
	else:
		# Fallback: manually clear locked, then open
		if ceo_door.has_method("open"):
			ceo_door.locked = false
			ceo_door.open()


	# Small suspense pause with door open + monster there
	await get_tree().create_timer(2.0).timeout

	# 3) DISTRACTION SOUND FAR AWAY
	if monster_distraction_target:
		var p := monster_distraction_target.global_position

		# Optional: direct command to monster if you implement it
		if monster.has_method("go_to_distraction"):
			monster.go_to_distraction(p)

	# Give monster a bit of time to "walk away"
	await get_tree().create_timer(3.0).timeout
	
	if monster and monster.has_method("end_tutorial_and_enable_normal_ai"):
		monster.end_tutorial_and_enable_normal_ai()
	else:
		# Fallback: manually disable tutorial mode
		monster.tutorial_mode = false
		if monster.states.has("roaming"):
			monster.curr_state = monster.states["roaming"]
	# 4) RETURN CONTROL TO PLAYER – TUTORIAL ESCAPE PHASE
	player.set_tutorial_movement_locked(false)
	player.set_ui_locked(false)

	step = Step.ESCAPE
	if objective_ui:
		objective_ui.mark_completed()
		objective_ui.set_objective("Escape the office.")
	if controls_ui:
		_show_tutorial_controls("SHIFT: Sprint\nCTRL: Crouch to stay quiet")
