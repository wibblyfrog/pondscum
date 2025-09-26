extends Node

func _create_server():
    var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    if peer.create_server(7777, 32) != OK:
        push_error("Failed to create server")
        return 
    print_debug("Server created, waiting for clients...")
    multiplayer.multiplayer_peer = peer
    
    # Add server player
    add_player(1)

func _create_client():
    var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    if peer.create_client("127.0.0.1", 7777) != OK:
        push_error("Failed to create client")
        return
    print_debug("Client created, connecting to server...")
    multiplayer.multiplayer_peer = peer

func add_player(id: int):
    var player_scene: PackedScene = preload("res://actors/player/player.tscn")
    var player_instance: Node3D = player_scene.instantiate()
    player_instance.name = "Player_%d" % id
    player_instance.set_multiplayer_authority(id)
    var player_controller: Node = player_instance.get_node("PlayerController")
    player_controller.player = id
    get_node("PlayerSpawnPoint").add_child(player_instance)
    print_debug("Player %d added" % id)