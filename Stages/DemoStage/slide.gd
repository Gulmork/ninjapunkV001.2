extends State
class_name PlayerSlide

@export var player: Player

# Slide Tuning
@export var slide_friction: float = 5.0 
@export var stop_threshold: float = 20.0 

func enter() -> void:
	# 1. Play the Slide animation
	player.anim_playback.travel("slide")
	
	player.can_dash_walljump = true
	player.last_wall_normal = 0
	
	# Preserve 75% of incoming velocity for the slide
	player.velocity.x = player.velocity.x * 0.75 

func physics_update(delta: float) -> void:
	# Slide exponential decay
	player.velocity.x = lerp(player.velocity.x, 0.0, slide_friction * delta)
	
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# 2. Trigger the Shadowstep
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "shadowstep")
		return

	# 3. Future Slide Attack hook goes here
	# if Input.is_action_just_pressed("attack"):
	#     Transitioned.emit(self, "slide_attack")
	#     return

	# 4. Slide ends naturally
	if abs(player.velocity.x) < stop_threshold:
		player.velocity.x = 0
		var walk_input := Input.get_axis("move_left", "move_right")
		if walk_input != 0:
			Transitioned.emit(self, "walk")
		else:
			Transitioned.emit(self, "idle")
			
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
