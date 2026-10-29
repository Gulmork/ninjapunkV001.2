class_name State
extends Node

# Emitted when the state wants to change to another state
signal Transitioned(state: State, new_state_name: String)

func enter() -> void:
	# Called once when entering the state (e.g., play animation)
	pass

func exit() -> void:
	# Called once when exiting the state (e.g., reset variables)
	pass

func update(_delta: float) -> void:
	# Equivalent to _process(). For frame-by-frame logic.
	pass

func physics_update(_delta: float) -> void:
	# Equivalent to _physics_process(). For physics and movement.
	pass
