class_name Level
extends Node3D

@onready var mpc: MultiPlayCore = get_parent()
@onready var pcam: PhantomCamera3D = $PhantomCamera3D

func _ready() -> void:
	mpc.connected_to_server.connect(_on_connected_to_server)
	mpc.connection_error.connect(_on_connection_error)	
	
func _on_connected_to_server(localplayer) -> void:
	pcam.follow_mode = PhantomCamera3D.FollowMode.THIRD_PERSON
	pcam.follow_target = localplayer.player_node as Character
	pcam.follow_offset.y = .75
	pcam.spring_length = 5.0
	pcam.set_shape(SeparationRayShape3D.new())
	pcam.set_third_person_rotation_degrees(Vector3(-60, 0, 0))

	localplayer.player_node.pcam = pcam

func _on_connection_error(_reason) -> void:
	pass