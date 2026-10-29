extends State
class_name PlayerDash

@export var player: Player

@export var base_dash_speed: float = 520.0  # Increased from 400 — feels like a real burst
@export var dash_multiplier: float = 1.5   

var _current_dash_time: float = 0.0
var _dash_direction: float = 1.0
var _burst_speed: float = 0.0 

func enter() -> void:
	player.anim_playback.travel("dash")
	_current_dash_time = 0.0
	
	var input_dir := Input.get_axis("move_left", "move_right")
	
	# 1. DIRECCIÓN BASE (player input, then facing direction as fallback)
	if input_dir != 0:
		_dash_direction = sign(input_dir)
	elif player.facing_direction != 0:
		_dash_direction = sign(player.facing_direction)
	else:
		_dash_direction = 1.0

	# 2. WALL DASH OVERRIDE
	# Only redirect if in the air, touching a wall, AND actively pressing into it.
	# Does NOT override free-air directional input.
	if not player.is_on_floor():
		var wall_normal_x = player.get_wall_normal().x
		if wall_normal_x != 0:
			var pressing_into_wall = (sign(input_dir) == -sign(wall_normal_x))
			if pressing_into_wall:
				_dash_direction = sign(wall_normal_x)
		
	# 3. Visual direction
	player.facing_direction = _dash_direction
	player.get_node("Sprite2D").flip_h = (_dash_direction > 0)
	
	# 4. Burst speed — takes current momentum into account if already moving fast
	var current_speed = abs(player.velocity.x)
	_burst_speed = max(base_dash_speed, current_speed * dash_multiplier)

func physics_update(delta: float) -> void:
	_current_dash_time += delta
	
	# Dash is a committed horizontal burst — gravity is suspended
	player.velocity.x = _dash_direction * _burst_speed
	player.velocity.y = 0.0
	player.move_and_slide()
	
	# Jump cancels the dash early (already had this — keeping it)
	if Input.is_action_just_pressed("jump") and player.can_jump:
		Transitioned.emit(self, "jump")
		return
		
	# End of dash transitions
	if _current_dash_time >= player.dash_duration:
		if player.is_on_floor():
			if Input.is_action_pressed("ui_down"):
				Transitioned.emit(self, "slide")
			else:
				var walk_input := Input.get_axis("move_left", "move_right")
				if walk_input != 0:
					Transitioned.emit(self, "walk")
				else:
					Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "fall")
