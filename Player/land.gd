extends State
class_name PlayerLand

@export var player: Player

func enter() -> void:
	player.anim_playback.travel("land")
	
	player.can_dash_walljump = true
	player.last_wall_normal = 0
	
	if player.has_shadow_stepped:
		# HARD STOP from a Shadow Step
		player.velocity.x = 0
		player.has_shadow_stepped = false 
	else:
		# Normal, low-speed landing friction (slows them down quickly)
		player.velocity.x = player.velocity.x * 0.3 

func physics_update(delta: float) -> void:
	# Quickly bleed off any remaining low speed
	player.velocity.x = lerp(player.velocity.x, 0.0, 15.0 * delta)
	
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# Normal jumps are allowed here, but not Shadow Steps (since they aren't sliding)
	if Input.is_action_just_pressed("jump") and player.can_jump:
		Transitioned.emit(self, "jump")
		return
	
	# Context-Sensitive Crouch / Slide
	if Input.is_action_just_pressed("ui_down"):
		if abs(player.velocity.x) >= player.min_slide_velocity:
			Transitioned.emit(self, "slide")
		else:
			Transitioned.emit(self, "crouch")
		return
	
	# Quickly transition to idle or walk
	if abs(player.velocity.x) < 10.0:
		player.velocity.x = 0
		var walk_input := Input.get_axis("move_left", "move_right")
		if walk_input != 0:
			Transitioned.emit(self, "walk")
		else:
			Transitioned.emit(self, "idle")
