extends Entity
class_name Player

# Emitted when the player movement has stopped.
signal movement_stopped()
signal status_values_changed(changed_values)

var can_move: bool = true

func _ready():
	PubSub.subscribe(PST.TERRAIN_CLICKED, self)
	PubSub.subscribe(PST.PLAYER_MOVE_REQUSTED, self)


func free():
  PubSub.unsubscribe(self)
  .free()


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func move_to(destination):
	if !can_move:
		return
	$MoveIndicator.translation = destination
	$MoveIndicator.play()


func event_published(event_key, payload) -> void:
  match (event_key):
    PST.TERRAIN_CLICKED, PST.PLAYER_MOVE_REQUSTED:
      move_to(payload)