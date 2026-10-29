extends State
class_name PlayerCrouch

@export var player: Player

func enter() -> void:
	# Travel to your crouch animation
	player.anim_playback.travel("crouch")
	
	# Stop horizontal movement instantly when crouching
	player.velocity.x = 0

func physics_update(delta: float) -> void:
	# Keep gravity active
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# Exit crouch when the button is released
	if Input.is_action_just_released("ui_down"):
		Transitioned.emit(self, "idle")
		return
		
	# Fall if the floor disappears
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
