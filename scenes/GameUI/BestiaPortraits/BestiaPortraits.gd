extends VBoxContainer

func _ready():
	# I am not sure how to handle this properly. Find a good way in order
	# to handle this. Maybe a own component only containing these entities?
	# Maybe filtering the player entities?
	# PubSub.subscribe(PST.ENTITY_ADDED, self)
	# PubSub.subscribe(PST.ENTITY_REMOVED, self)
	# PubSub.subscribe(PST.SERVER_RECEIVE, self)
	pass


func free():
	PubSub.unsubscribe(self)
	.free()
