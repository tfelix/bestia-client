class_name ChatMessage

enum ChatType {
	PUBLIC,
	PARTY,
	GUILD,
	WHISPER,
	SYSTEM,
	ERROR
}

var entity_id: int
var username: String
var text: String
var type = ChatType.PUBLIC