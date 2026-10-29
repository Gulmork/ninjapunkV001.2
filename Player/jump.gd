extends State
class_name PlayerJump

@export var player: Player

func enter() -> void:
	player.anim_playback.travel("jump")
	player.velocity.y = player.jump_velocity

func physics_update(delta: float) -> void:
	# 1. Jump arc uses BASE gravity — lighter, gives the player time to aim
	player.velocity.y += player.gravity * delta
	
	# 2. Control de Movimiento y Momentum
	var input_dir = Input.get_axis("move_left", "move_right")
	
	if input_dir != 0:
		player.facing_direction = input_dir
		player.get_node("Sprite2D").flip_h = (input_dir > 0)
		
		# Momentum: conserve speed if already moving faster than walk speed
		if abs(player.velocity.x) > player.movement_speed and sign(player.velocity.x) == sign(input_dir):
			player.velocity.x = move_toward(player.velocity.x, input_dir * player.movement_speed, 500.0 * delta)
		else:
			player.velocity.x = input_dir * player.movement_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 800.0 * delta)
		
	# 3. Aplicar físicas
	player.move_and_slide()
	
	# 4. TRANSICIONES
	
	# Jump-dash: cancel vertical momentum and commit to dash direction
	if Input.is_action_just_pressed("dash") and player.can_air_dash:
		player.can_air_dash = false
		player.velocity.y = 0.0  # Zero out vertical so dash feels horizontal and clean
		Transitioned.emit(self, "dash")
		return

	# Transition to fall once upward momentum is spent
	if player.velocity.y >= 0.0:
		Transitioned.emit(self, "fall")
		return
