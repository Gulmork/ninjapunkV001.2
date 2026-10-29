extends State
class_name PlayerWalk

@export var player: Player

func enter() -> void:
	player.anim_playback.travel("walk")
	
	# Restaurar mecánicas al tocar el suelo por si acaso
	player.can_dash_walljump = true
	player.last_wall_normal = 0

func physics_update(delta: float) -> void:
	# 1. Leer el Input del jugador
	var input_dir := Input.get_axis("move_left", "move_right")
	
	# 2. TRANSICIÓN A IDLE: Si el jugador suelta las teclas, dejamos de caminar
	if input_dir == 0:
		Transitioned.emit(self, "idle")
		return
		
	# 3. Aplicar Movimiento y Dirección
	player.facing_direction = sign(input_dir)
	player.get_node("Sprite2D").flip_h = (input_dir > 0)
	player.velocity.x = input_dir * player.movement_speed
	
	# 4. Aplicar Gravedad (por si caminamos hacia un precipicio)
	player.velocity.y += player.gravity * delta
	
	# 5. Aplicar Físicas
	player.move_and_slide()
	
	# 6. OTRAS TRANSICIONES
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		return
		
	if Input.is_action_just_pressed("jump") and player.can_jump:
		Transitioned.emit(self, "jump")
		return
		
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "dash")
		return
		
	if Input.is_action_just_pressed("ui_down"):
		if abs(player.velocity.x) >= player.min_slide_velocity:
			Transitioned.emit(self, "slide")
		else:
			Transitioned.emit(self, "crouch")
		return
