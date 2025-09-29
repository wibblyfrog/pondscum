extends Control

@export var mpc: MultiPlayCore

func _ready() -> void:
    mpc.connected_to_server.connect(_on_connected_to_server)
    mpc.connection_error.connect(_on_connection_error)

func _on_join_button_pressed() -> void:
    mpc.start_online_join(%JoinAddressInput.text + ":" + %JoinPortInput.text)

func _on_host_button_pressed() -> void:
    mpc.port = int(%HostPortInput.text)
    mpc.max_players = int(%PlayerCount.value)
    mpc.start_online_host(true)

func _on_connected_to_server(localplayer) -> void:
    hide()

func _on_connection_error(reason) -> void:
    show()