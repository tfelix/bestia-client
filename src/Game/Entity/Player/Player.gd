extends KinematicBody
class_name Player

# Maybe put this in own state node
enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING,
	USE,
	PICKUP,
	INTERACTING # e.g. talking with npc
}

class PlayerCommand:
	var state = PlayerState.IDLE
	var target_entity: Entity = null
	var target_point: Vector3 = Vector3.INF
	var casted_attack = null


var _next_command: PlayerCommand = null
var _current_command: PlayerCommand = null

var _can_move = true
var _has_attack_delay = false

export var walkspeed = 5.0
export var attack_range = 10.0
export var attack_delay = 2.0
export var player_name = "John Doe"

onready var _character_label = $NameFollower/CharacterLabel
onready var _model = $Mannequiny
onready var _move_cursor = $MoveCursor
onready var _attack_delay_timer = $AttackDelay
onready var _entity = $Entity

func _ready():
	GlobalEvents.connect("terrain_clicked", self, "_terrain_clicked")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
	GlobalEvents.connect("onPlayerAttacked", self, "_attack")
	GlobalEvents.connect("onPlayerUsed", self, "_use")
	GlobalEvents.connect("onSkillCasted", self, "_cast_attack_on_entity")
	GlobalEvents.connect("onPlayerItemPicked", self, "_pick_item")
	
	# This seems to be a bug in godot. in order to get mouse over events
	# we must disable and enable raycasting detection.
	input_ray_pickable = false
	input_ray_pickable = true
	# As we might be already attached under the Entities node it might not
	# be subscribed to the entity signal. To give it a chance to subscribe
	# we need to call announce entity deferred.
	call_deferred("_announce_entity")


func _started_construction(entity) -> void:
	_can_move = false


func _ended_construction(entity) -> void:
	_can_move = true


func _process(delta):
	if _current_command == null:
		if _next_command != null:
			_current_command = _next_command
			_next_command = null
			_execute_command(_current_command)


func _physics_process(delta):
	# We only care about moving states.
	if _current_command == null:
		_model.transition_to(Mannequiny.States.IDLE)
		return
	
	if _current_command.state != PlayerState.MOVING:
		return
	
	
	var move_target = _current_command.target_point
	if move_target == Vector3.INF:
		_current_command = null
		return
	
	var global_pos = global_transform.origin
	var target_delta = (move_target - global_pos).length()
	
	if target_delta <= 0.1:
		_current_command = null
		_model.transition_to(Mannequiny.States.IDLE)
		return

	var velocity = (move_target - global_pos).normalized() * walkspeed
	
	_model.transition_to(Mannequiny.States.RUN)
	move_and_slide_with_snap(velocity, Vector3.UP)


func _execute_command(cmd: PlayerCommand) -> void:
	_current_command = cmd
	if cmd.state == PlayerState.ATTACKING:
		var target_entity = cmd.target_entity
		_attack(target_entity)
	elif cmd.state == PlayerState.USE:
		var target_entity = cmd.target_entity
		if target_entity != null:
			_use(target_entity)
	elif cmd.state == PlayerState.PICKUP:
		var target_entity = cmd.target_entity
		if target_entity != null:
			_pick_item(target_entity)


func _cast_attack_on_entity(attack, entity, target) -> void:
	look_at(entity.global_transform.origin, Vector3.UP)
	
	# Check if target is in range, if its not, then do nothing.
	var msg = UseAttackMessage.new()
	msg.player_attack_id = attack
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)
	
	_next_command = null


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _terrain_clicked(global_pos: Vector3) -> void:
	# We ignore movement clicks if we are currently constructing
	if not _can_move:
		return
	_play_move_marker(global_pos)
	# We cancel all queued actions
	_next_command = null
	_move_to(global_pos)


"""
Tries to move the player to this position. This is a high level action
and will cancel all other queued commands.
"""
func _move_to(global_pos: Vector3) -> void:
	# If the entity is currently marked as non movable we stop movement here.
	if _entity.get_component(NoMovementComponent.NAME) != null:
		return
	
	# Cancel the casting target selection.
	GlobalEvents.emit_signal("onCastSelectionEnded")
	
	look_at(global_pos, Vector3.UP)
	
	var cmd = PlayerCommand.new()
	cmd.state = PlayerState.MOVING
	cmd.target_point = global_pos
	_current_command = cmd


func _play_move_marker(position: Vector3) -> void:
	_move_cursor.global_transform.origin = position
	_move_cursor.play()


func _pick_item(item_entity: Entity) -> void:
	var target_origin = item_entity.get_spatial().global_transform.origin
	var target_distance = target_origin.distance_to(global_transform.origin)
	
	var in_pick_range = target_distance < 1.0
	if  in_pick_range:
		_current_command = null
		var msg = PickupItemRequestMessage.new()
		msg.entity_id = item_entity.id
		GlobalEvents.emit_signal("onMessageSend", msg)
	else:
		_current_command = null
		_next_command = null
		_move_to_distance_from_entity(0.1, item_entity)
		
		var use_cmd = PlayerCommand.new()
		use_cmd.state = PlayerState.PICKUP
		use_cmd.target_entity = item_entity
		_next_command = use_cmd


func _use(target_entity: Entity) -> void:
	# Check if we are in usable range.
	# Yes, use item -> call use on structure.
	# No, try to close distance and re-check usability
	var target_origin = target_entity.get_spatial().global_transform.origin
	var target_distance = target_origin.distance_to(global_transform.origin)
	
	var in_use_range = true
	if  in_use_range:
		target_entity.use(_entity)
	else:
		var use_cmd = PlayerCommand.new()
		use_cmd.state = PlayerState.USE
		use_cmd.target_entity = target_entity
		_next_command = use_cmd
		
		_move_to_distance_from_entity(0.1, target_entity)


func _attack(target_entity: Entity) -> void:
	if _has_attack_delay:
		return
	
	var target_origin = target_entity.get_spatial().global_transform.origin
	look_at(target_origin, Vector3.UP)
	
	var atk_cmd = PlayerCommand.new()
	atk_cmd.state = PlayerState.ATTACKING
	atk_cmd.target_entity = target_entity
	_next_command = atk_cmd
	
	# Check if we need to move towards our target before we can perform the attack
	var target_distance = target_origin.distance_to(global_transform.origin)
	if  attack_range < target_distance:
		_move_to_distance_from_entity(attack_range, target_entity)
		return
	
	# TODO diffeentiate between melee or ranged depending on equip component
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onMessageSend", atk_msg)

	_has_attack_delay = true
	_attack_delay_timer.wait_time = attack_delay
	_attack_delay_timer.start()


func _move_to_distance_from_entity(distance: float, target_entity: Entity) -> void:
	# We want to keep some safety margin for rounding errors.
	distance -= 0.5
	var target_origin = target_entity.get_spatial().global_transform.origin
	var offset_vec = (target_origin - global_transform.origin).normalized() * distance
	var target = target_origin - offset_vec
	_move_to(target)


func _on_AttackDelay_timeout():
	_has_attack_delay = false


# Executes the next queued command.
func _on_InteractionRange_body_entered(body):
	_current_command = null


func _on_Entity_mouse_entered():
	_character_label.visible = true


func _on_Entity_mouse_exited():
	_character_label.visible = false


func _on_Entity_component_updated(component):
	if component is PlayerComponent:
		_character_label.set_data(component)
	if component.walkspeed:
		walkspeed = component.walkspeed
