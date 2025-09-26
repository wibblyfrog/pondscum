extends CharacterBody3D
class_name PlayerController

@export var player: int = 0:
	set(id):
		player = id

@export var MOVE_SPEED := 12
@export var JUMP_FORCE := 15
@export var GRAVITY := 0.98
@export var MAX_FALL_SPEED := 30

var mouse_sensitivity: float = 0.05
var min_yaw: float = 0
var max_yaw: float = 360
var min_pitch: float = -89.9
var max_pitch: float = 50

@export var pcam: PhantomCamera3D

var input_direction: Vector2 = Vector2.ZERO
var just_jumped: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false: return
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Mouse Look
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
	

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority() == false: return

	# Movement
	var move_vector := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		move_vector.z -= 1
	elif Input.is_action_pressed("move_backward"):
		move_vector.z += 1
	if Input.is_action_pressed("move_left"):
		move_vector.x -= 1
	elif Input.is_action_pressed("move_right"):
		move_vector.x += 1
	move_vector = move_vector.normalized()
	# Move relative to camera
	move_vector = move_vector.rotated(Vector3.UP, pcam.get_third_person_rotation_degrees().y * (PI / 180))
	move_vector *= MOVE_SPEED
	move_vector.y = velocity.y

	velocity = move_vector

	# Jumping
	velocity.y -= GRAVITY
	just_jumped = false
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		just_jumped = true
		velocity.y = JUMP_FORCE
	if is_on_floor() and velocity.y <= 0:
		velocity.y = -0.1
	if velocity.y < -MAX_FALL_SPEED:
		velocity.y = -MAX_FALL_SPEED
	
	move_and_slide()

	# Smoothly rotate player to face movement direction
	var horizontal_move = Vector3(move_vector.x, 0, move_vector.z)
	if horizontal_move.length() > 0.01:
		var target_direction = horizontal_move.normalized()
		var target_rotation = atan2(-target_direction.x, -target_direction.z)
		var current_rotation = rotation.y
		var lerped_rotation = lerp_angle(current_rotation, target_rotation, 0.15)
		rotation.y = lerped_rotation