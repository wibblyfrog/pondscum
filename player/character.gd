extends CharacterBody3D
class_name Character

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var mpp: MPPlayer = get_parent()

var pcam: PhantomCamera3D
var mouse_sensitivity: float = 0.05

var min_yaw: float = 0
var max_yaw: float = 360

var min_pitch: float = -89.9
var max_pitch: float = 50

func _unhandled_input(event) -> void:
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.is_pressed():
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		if not pcam: return	# Wait for pcam to be ready
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector(mpp.ma("move_left"), mpp.ma("move_right"), mpp.ma("move_up"), mpp.ma("move_down"))
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if pcam:
		direction = direction.rotated(Vector3.UP, pcam.get_third_person_rotation().y)

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
