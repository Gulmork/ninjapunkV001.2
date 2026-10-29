extends State
class_name PlayerFall

@export var player: Player

func enter() -> void:
	player.anim_playback.travel("fall")

func physics_update(delta: float) -> void:
	# 1. Fall uses SCALED gravity — drops faster than the rise for snappy, readable arcs
	player.velocity.y += player.gravity * player.fall_gravity_multiplier * delta
	
	# 2. Movement and Momentum Control
	var input_dir = Input.get_axis("move_left", "move_right")
	
	if input_dir != 0:
		player.facing_direction = input_dir
		player.get_node("Sprite2D").flip_h = (input_dir > 0)
		
		if abs(player.velocity.x) > player.movement_speed and sign(player.velocity.x) == sign(input_dir):
			player.velocity.x = move_toward(player.velocity.x, input_dir * player.movement_speed, 500.0 * delta)
		else:
			player.velocity.x = input_dir * player.movement_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 800.0 * delta)
		
	# 3. Apply physics so is_on_floor() and is_on_wall() are accurate this frame
	player.move_and_slide()
	
	# 4. TRANSITIONS
	
	# A) Wall Hang
	if player.is_on_wall() or player.wall_ray.is_colliding():
		if input_dir != 0:
			var current_wall_normal = int(sign(player.get_wall_normal().x))
			if current_wall_normal != player.last_wall_normal:
				Transitioned.emit(self, "wallhang")
				return
			
	# B) Landing
	if player.is_on_floor():
		player.can_air_dash = true
		Transitioned.emit(self, "land")
		return

	# C) Air Dash
	if Input.is_action_just_pressed("dash") and player.can_air_dash:
		player.can_air_dash = false
		player.velocity.y = 0.0  # Zero vertical so dash reads as horizontal burst
		Transitioned.emit(self, "dash")
		return
