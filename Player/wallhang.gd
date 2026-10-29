extends State
class_name PlayerWallHang

@export var player: Player
# Maximum time the player can remain hanging in seconds
@export var max_hang_time: float = 0.35 

var _hang_timer: float = 0.0
var current_hang_time: float = 0.0

func enter() -> void:
	player.anim_playback.travel("wallhang")
	player.velocity = Vector2.ZERO
	player.gravity = 0 
	
	current_hang_time = 0.0
	
	# Reset the timer every time we touch a wall
	_hang_timer = 0.0
	
	if player.is_on_wall():
		player.last_wall_normal = int(sign(player.get_wall_normal().x))
	
	print("Entered WallHang State")

func exit() -> void:
	# Restore system gravity on state exit
	player.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func physics_update(delta: float) -> void:
	# 1. Handle maximum hang duration time-out
	current_hang_time += delta

	_hang_timer += delta
	if _hang_timer >= max_hang_time:
		print("Wall hang time limit reached. Falling...")
		Transitioned.emit(self, "fall")
		return
	
	var input_dir = Input.get_axis("move_left", "move_right")
	
	
	# Drop down if holding the analog stick away from the wall
	if input_dir != 0 and input_dir != player.facing_direction:
		Transitioned.emit(self, "fall")
		return
	
	# 2. Wall Jump Trigger
	# FIXED: Changed from "wall_jump" to "walljump" to match your FSM registration keys
	if Input.is_action_just_pressed("jump"):
		print("Wall jump triggered from WallHang state")
		Transitioned.emit(self, "walljump")
		return
	if current_hang_time >= max_hang_time:
		Transitioned.emit(self, "fall")
		return
			
	if input_dir == player.last_wall_normal:
		Transitioned.emit(self, "fall")
