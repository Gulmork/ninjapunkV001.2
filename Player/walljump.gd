extends State
class_name PlayerWallJump

@export var player: Player

func enter() -> void:
	# 1. Play the Wall Jump animation
	# MAKE SURE the string matches your node name in the AnimationTree exactly!
	player.anim_playback.travel("walljump") 
	
	# Jump direction (away from the wall)
	var jump_direction = player.last_wall_normal 
	
	# 2. Update Sprite Direction
	# Make the player face the new direction they are jumping towards
	player.facing_direction = jump_direction
	player.get_node("Sprite2D").flip_h = (jump_direction > 0)
	# Jump in the opposite direction of the wall we are releasing from
	
	# Check if the player wants to execute a Dash Walljump and if they have the charge available
	var is_pressing_dash = Input.is_action_pressed("dash") # Make sure the input name matches yours
	
	if is_pressing_dash and player.can_dash_walljump:
		# EXECUTE DASH WALLJUMP (Full force)
		player.velocity.x = jump_direction * player.dash_walljump_velocity.x
		player.velocity.y = player.dash_walljump_velocity.y
		
		# Consume the charge. They won't be able to do it again until they touch the ground.
		player.can_dash_walljump = false 
	else:
		# EXECUTE NORMAL WALLJUMP (Half force)
		player.velocity.x = jump_direction * player.normal_walljump_velocity.x
		player.velocity.y = player.normal_walljump_velocity.y

func physics_update(delta: float) -> void:
	# Apply gravity during the jump
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# 1. Transition to wallhang if we hit a NEW wall (parallel wall logic)
	# FIX: Changed "wall_hang" to "wallhang" to match the FSM-registered state name.
	# The FSM registers states using child.name.to_lower(), so node "WallHang" = "wallhang".
	if player.is_on_wall():
		var current_wall_normal = int(sign(player.get_wall_normal().x))
		if current_wall_normal != player.last_wall_normal:
			Transitioned.emit(self, "wallhang")
			return
			
	# 2. Transition to fall state when upward momentum ends
	if player.velocity.y >= 0:
		Transitioned.emit(self, "fall")
