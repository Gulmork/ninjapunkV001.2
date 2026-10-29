class_name CameraArea
extends Node2D

@onready var jurisdiction = $JurisdictionPolygon
@onready var boundary = $BoundaryPolygon

# Pre-calculamos un rectángulo rápido para optimizar (como dice el video)
var _jurisdiction_rect: Rect2

func _ready() -> void:
	# Ocultamos los polígonos en el juego final, solo son para el editor
	jurisdiction.hide()
	boundary.hide()
	
	# Calcular el Rect2 que encierra al polígono para optimización [06:12]
	var points = jurisdiction.polygon
	if points.size() > 0:
		var min_x = points[0].x
		var max_x = points[0].x
		var min_y = points[0].y
		var max_y = points[0].y
		
		for p in points:
			min_x = min(min_x, p.x)
			max_x = max(max_x, p.x)
			min_y = min(min_y, p.y)
			max_y = max(max_y, p.y)
		
		_jurisdiction_rect = Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

# Función para saber si el jugador está dentro de la jurisdicción [05:51]
func is_point_inside(point: Vector2) -> bool:
	# 1. Chequeo rápido y barato con el Rect2 [06:19]
	if not _jurisdiction_rect.has_point(point):
		return false
	
	# 2. Chequeo exacto y costoso con Geometry2D
	return Geometry2D.is_point_in_polygon(point, jurisdiction.polygon)

# Función para encerrar la cámara dentro de los límites [07:19]
func get_bound_position(desired_pos: Vector2) -> Vector2:
	if Geometry2D.is_point_in_polygon(desired_pos, boundary.polygon):
		return desired_pos # Ya está dentro de los límites
	
	# Si se sale, buscamos el punto más cercano en el borde del polígono
	var closest_point = desired_pos
	var min_dist = INF
	var points = boundary.polygon
	
	for i in range(points.size()):
		var p1 = points[i]
		var p2 = points[(i + 1) % points.size()]
		var closest_on_segment = Geometry2D.get_closest_point_to_segment(desired_pos, p1, p2)
		var dist = desired_pos.distance_squared_to(closest_on_segment)
		if dist < min_dist:
			min_dist = dist
			closest_point = closest_on_segment
			
	return closest_point
