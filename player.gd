class_name Player
extends CharacterBody2D

# Adjustable values from Inspector to calibrate gameplay feel
@export var movement_speed: float = 320.0
@export var jump_velocity: float = -500.0
@export var dash_speed: float = 550.0
@export var dash_duration: float = 0.22 # Snappier dash duration
@export var normal_walljump_velocity: Vector2 = Vector2(200, -400)
@export var dash_walljump_velocity: Vector2 = Vector2(500, -500)
@export var min_slide_velocity: float = 315.0

# Gravity tuning: fall drops faster than rise for snappy, readable jumps
@export var fall_gravity_multiplier: float = 1.8

var can_air_dash: bool = true
# 1.0 is right, -1.0 is left.
var facing_direction: float = 1.0
var can_dash_walljump: bool = true
var last_wall_normal: int = 0
var is_invincible: bool = false
var can_jump: bool = true
# Base gravity from project settings — states scale this themselves
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_shadow_stepped: bool = false

# AnimationTree reference
@onready var anim_tree: AnimationTree = $AnimationTree

# AnimationTree playback controller reference
@onready var anim_playback = anim_tree.get("parameters/playback")

@onready var wall_ray = $WallRay

var is_control_locked: bool = false

func _on_control_lock_timer_timeout():
	is_control_locked = false

func _physics_process(_delta: float) -> void:
	wall_ray.target_position.x = 25 * facing_direction
	wall_ray.force_raycast_update()

func grant_iframes(duration: float) -> void:
	is_invincible = true
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_on_iframes_ended)

func _on_iframes_ended() -> void:
	is_invincible = false
