extends State
class_name PlayerIdle

@export var player: Player

func enter() -> void:
	player.anim_playback.travel("idle")
	player.can_jump = true
	player.velocity.x = 0
	player.last_wall_normal = 0
	
func physics_update(_delta: float) -> void:
	# Important: Transition to fall if ground disappears
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return

	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "dash")
		return
	# Context-Sensitive Crouch / Slide
	if Input.is_action_just_pressed("ui_down"):
		if abs(player.velocity.x) >= player.min_slide_velocity:
			Transitioned.emit(self, "slide")
		else:
			Transitioned.emit(self, "crouch")
		return
	
	# TRANSITIONS
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		Transitioned.emit(self, "walk")
		return
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Transitioned.emit(self, "jump")
		return

	player.move_and_slide()
