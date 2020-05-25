extends Control


onready var _http = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(_http)
	_http.connect("request_completed", self, "_http_request_completed")
	 # Perform the HTTP request. The URL below returns some JSON as of writing.
	var register = {
		"uername": "test",
		"gender": "MALE",
		"hairstyle": "",
		"hairColor": "#AABBCC",
		"skinColor": "#AABBCC",
		"playerMaster": 1,
		"basicLogin": {
			"email": "abc@example.com",
			"password": "password"
		}
	}
	var payload = JSON.print(register)
	var error = _http.request(
		"http://localhost:8080/account", 
		[],
		true,
		HTTPClient.METHOD_POST,
		payload
		)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(response.headers["User-Agent"])
