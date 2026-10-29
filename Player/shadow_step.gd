extends State
class_name PlayerShadowStep

@export var player: Player

# Shadow Step Tuning
@export var horizontal_force: float = 350.0 
@export var vertical_lift: float = -150.0 
@export var iframe_duration: float = 0.3 

func enter() -> void:
	# 1. Play the Shadowstep animation
	player.anim_playback.travel("shadowstep")
	
	# 2. Determine direction
	var step_dir := Input.get_axis("move_left", "move_right")
	if step_dir == 0:
		# If no input, step in the direction we are moving, or facing
		if player.velocity.x != 0:
			step_dir = sign(player.velocity.x)
		else:
			step_dir = player.facing_direction
			
	# Update visual orientation
	player.get_node("Sprite2D").flip_h = (step_dir > 0)
	
	# 3. Apply the Shadowstep forces
	player.velocity.x = step_dir * horizontal_force
	player.velocity.y = vertical_lift
	
	# 4. Grant i-frames
	if player.has_method("grant_iframes"):
		player.grant_iframes(iframe_duration)
		
	# 5. Tell the player script we executed this move (for the hard stop upon landing)
	player.has_shadow_stepped = true

func physics_update(delta: float) -> void:
	# Apply gravity during the tiny hop
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# Transition to fall as soon as the upward lift is over
	if player.velocity.y >= 0:
		Transitioned.emit(self, "fall")
