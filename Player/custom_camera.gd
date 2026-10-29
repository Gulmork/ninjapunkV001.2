extends Camera2D

@export var player: Player
@export var smooth_speed: float = 5.0
@export var look_ahead_amount: float = 100.0 # Para ver hacia dónde corremos [06:56]
@export var vertical_offset: float = -50.0

var active_area: CameraArea
var all_areas: Array[Node]

func _ready() -> void:
	# Obtenemos todas las áreas del nivel [05:35]
	all_areas = get_tree().get_nodes_in_group("camera_areas")

func _process(delta: float) -> void:
	if not player: return
	
	var player_pos = player.global_position
	
	# 1. ¿En qué área estamos?
	for area in all_areas:
		# Aquí va el seguro de vida, DENTRO del for:
		if area.has_method("is_point_inside"):
			if area.is_point_inside(player_pos):
				active_area = area
				break # Este break ahora sí pertenece al bucle for
			
	if not active_area:
		return # Si estamos fuera de mapa, no movemos la cámara
		
	# 2. Calcular dónde QUEREMOS que esté la cámara [06:40]
	var desired_pos = player_pos
	desired_pos.y += vertical_offset
	
	# Look-ahead: mueve la cámara hacia donde miras/corres
	if player.velocity.x != 0:
		desired_pos.x += sign(player.velocity.x) * look_ahead_amount
		
	# 3. Limitar la cámara usando la lógica matemática del área [07:19]
	var bound_pos = active_area.get_bound_position(desired_pos)
	
	# 4. Movimiento suave (Lerp) [07:38]
	global_position = global_position.lerp(bound_pos, smooth_speed * delta)
