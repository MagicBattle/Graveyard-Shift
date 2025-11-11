class_name PlayerState
extends Node

enum State { IDLE, WALK, SPRINT, JUMP, CROUCH, THROWING }

signal state_changed(prev: State, next: State)

@export var value: State = State.IDLE:
	set = set_state

func set_state(next: State) -> void:
	if next == value:
		return
	var prev: State = value
	value = next
	state_changed.emit(prev, next)
	
	
func set_idle() -> void:
	set_state(State.IDLE)
	
	
func set_walk() -> void:
	set_state(State.WALK)
	
	
func set_sprint() -> void:
	set_state(State.SPRINT)
	
	
func set_jump() -> void:
	set_state(State.JUMP)
	
	
func set_crouch() -> void:
	set_state(State.CROUCH)
	
	
func set_throwing() -> void:
	set_state(State.THROWING)
