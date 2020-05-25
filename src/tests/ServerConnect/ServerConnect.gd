extends Control

const Proto = preload("res://protobuf/ProtoMessages.gd")

var socket: StreamPeerTCP
var wrapped_client

func _ready():
	socket = StreamPeerTCP.new()
	socket.set_no_delay(true)
	

func connect_to_server():
	if socket.is_connected_to_host():
		socket.disconnect_from_host()
	var ip = "127.0.0.1"
	var port = 8990
	print_debug("Connecting to server: %s : %s" % [ip, str(port)])
	var connect = socket.connect_to_host(ip, port)
	if socket.is_connected_to_host():
		print_debug("Connected to local host server")
		wrapped_client = PacketPeerStream.new()
		wrapped_client.set_stream_peer(socket)


func _on_Connect_pressed():
	connect_to_server()


func send_var(msg):
	if socket.is_connected_to_host():
		var auth = Proto.Auth.new()
		auth.set_accountId(1)
		auth.set_token("50cb5740-c390-4d48-932f-eef7cbc113c1")
		var packed_bytes = auth.to_bytes()
		print_debug("Packet Size: ", packed_bytes.size())
		wrapped_client.put_packet(packed_bytes)
		var error = wrapped_client.get_packet_error()
		if error != 0:
			printerr("Error on packet put: %s" % error)
	else:
		print_debug("Not connected")


func _on_Send_Data_pressed():
	send_var("Hello World")
