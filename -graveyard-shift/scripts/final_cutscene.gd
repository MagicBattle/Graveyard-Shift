extends Node3D

@onready var cinematicbars := $"../../TestingCharacter/CameraPivot/Camera3D/CinematicBars/Control"
@onready var player := $"../../TestingCharacter"
@onready var player_camera := $"../../TestingCharacter/CameraPivot/Camera3D"
@onready var camera_pivot := $"../../TestingCharacter/CameraPivot"
@onready var inventory_ui := $"../../TestingCharacter/Inventory/InventoryUI"
@onready var blue_light := $Decorations/CopLights/BlueLight
@onready var red_light := $Decorations/CopLights/RedLight
@onready var willie := $"../../Willie"
@onready var monster_state := $"../../Monster_State_Manager"
@onready var objective_ui := $"../../UI/PlayerScreen/ObjectiveUI"
@onready var codes_ui := $"../../UI/PlayerScreen/CodesUI"



@export var starting_position : Vector3 = Vector3(10.006,0,-12.471)



const MAX_LIGHT_ENERGY = 2.0
const SPEED = 10.0

var original_willie_position : Vector3
var toggle : bool = false
var cutscene_start : bool = false
var teleport_trigger : bool = false
var chase : bool = false
var camera_target_basis : Basis
var camera_target_basis_active : bool = false
var inside_final : bool = false


func _ready():
	blue_light.light_energy = 0.0
	red_light.light_energy = 0.0
	
	
func _process(delta):
	if inside_final:
		if cutscene_start or chase:
			_flash_cop_lights(delta)
		
		if teleport_trigger and cutscene_start:
			_teleport()
		
		if not chase:
			willie.animation_player.play("res://animations/willie/Idlev2.fbx")
			willie.animation_player.speed_scale = 0.05
			willie.dont_move()
		
		if chase:
			willie.animation_player.speed_scale = 1.0
			willie.change_state("chasing")
			willie.can_move()
		
		if camera_target_basis_active:
			camera_pivot.transform.basis = camera_pivot.transform.basis.slerp(camera_target_basis, 10.0 * delta)
			if camera_pivot.transform.basis.is_equal_approx(camera_target_basis):
				camera_pivot.transform.basis = camera_target_basis
				camera_target_basis_active = false
				await _initiate_final_run()	
	else:
		return


func _flash_cop_lights(delta):
	if toggle:
		blue_light.light_energy = lerp(blue_light.light_energy, 0.0, SPEED * delta)
		red_light.light_energy = lerp(red_light.light_energy, MAX_LIGHT_ENERGY, SPEED * delta)
	else:
		blue_light.light_energy = lerp(blue_light.light_energy, MAX_LIGHT_ENERGY, SPEED * delta)
		red_light.light_energy = lerp(red_light.light_energy, 0.0, SPEED * delta)
		
	if blue_light.light_energy >= MAX_LIGHT_ENERGY - 0.1:
		toggle = true
	elif blue_light.light_energy <= 0.1:
		toggle = false
		
		
#Triggers Cutscene Cutscene
func _on_cutscene_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and not teleport_trigger and not chase:
		cutscene_start = true
		cinematicbars.showbars()
		player.stamina_bar.visible = false
		player.throw_bar.visible = false
		inventory_ui.visible = false
		codes_ui.visible = false
		objective_ui.visible = false
	

func _on_teleport_monster_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and cutscene_start:
		original_willie_position = willie.global_position
		teleport_trigger = true
		

func _teleport():
	teleport_trigger = false
	cutscene_start = false
	var target_global = self.to_global(starting_position)
	willie.global_position = target_global	
	willie.look_at(player.global_transform.origin, Vector3.UP)
	player.stop_all_movement()
	willie.dont_move()
	
	camera_target_basis = Transform3D().looking_at(willie.global_transform.origin, Vector3.UP).basis
	
	camera_target_basis_active = true

		
func _on_win_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameManager._change_scene("res://scenes/end_credits.tscn")
		

func _initiate_final_run():
	cinematicbars.hidebars()
	await get_tree().create_timer(2.0).timeout
	player.continue_movement()
	chase = true

	
func _on_entering_final_rom_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		inside_final = true
