class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	print("FSM: Starting initialization...")
	
	# Wait for the parent node to be fully ready
	await get_parent().ready
	print("FSM: Parent is ready.")
	
	# Loop through children to find and register states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			print("FSM: Registered state: ", child.name)
	
	# Start the machine if an initial state is set
	if initial_state:
		print("FSM: Entering initial state: ", initial_state.name)
		initial_state.enter()
		current_state = initial_state
	else:
		push_error("FSM CRITICAL ERROR: initial_state is null. Assign it in the Inspector!")

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		print("Current state is: ", current_state.name)
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		push_warning("FSM WARNING: Tried to transition to non-existent state: ", new_state_name)
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
	
	print("Registered states: ", states.keys())
