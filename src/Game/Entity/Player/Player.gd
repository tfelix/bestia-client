extends KinematicBody
class_name Player

# Maybe put this in own state node
enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING,
	USE,
	INTERACTING # e.g. talking with npc
}

class PlayerCommand:
	var state = PlayerState.IDLE
	var target_entity: Entity = null
	var target_point: Vector3 = Vector3.INF
	var casted_attack = null

var _command_queue = []

var _has_attack_delay = false

onready var _model = $Mannequiny
onready var _move_cursor = $MoveCursor
onready var _attack_delay = $AttackDelay
onready var _entity = $Entity

func _ready():
	GlobalEvents.connect("onPlayerMoved", self, "_terrain_clicked")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
	GlobalEvents.connect("onPlayerInteract", self, "_on_player_interact")
	GlobalEvents.connect("onSkillCasted", self, "_cast_attack_on_entity")
	
	# This seems to be a bug in godot. in order to get mouse over events
	# we must disable and enable raycasting detection.
	input_ray_pickable = false
	input_ray_pickable = true
	# As we might be already attached under the Entities node it might not
	# be subscribed to the entity signal. To give it a chance to subscribe
	# we need to call announce entity deferred.
	call_deferred("_announce_entity")


func _started_construction(entity) -> void:
	pass
	#_current_state = PlayerState.CONSTRUCTING


func _ended_construction(entity) -> void:
	pass
	#_current_state = PlayerState.IDLE


func _physics_process(delta):
	# Check if we are in a moving state.
	if _is_in_state(PlayerState.IDLE):
		_model.transition_to(Mannequiny.States.IDLE)
		return
	
	if not _is_in_state(PlayerState.MOVING):
		return
	
	var move_target = (_command_queue[0] as PlayerCommand).target_point
	# Sanity check
	if move_target == Vector3.INF:
		return
	
	var global_pos = global_transform.origin
	var target_delta = (move_target - global_pos).length()
	
	if target_delta < 0.1:
		_command_queue.pop_front()
		_model.transition_to(Mannequiny.States.IDLE)
		_check_queued_actions()
		return

	if move_target == global_pos:
		return

	var status_comp = _entity.get_component(StatusComponent.NAME) as StatusComponent
	var speed = 5.0
	if status_comp != null:
		speed = status_comp.walkspeed
	var velocity = (move_target - global_pos).normalized() * speed
	
	move_and_slide_with_snap(velocity, Vector3.UP)


func _is_in_state(player_state) -> bool:
	# When no commands are queued the consider the player idling.
	if _command_queue.empty() == true:
		return player_state == PlayerState.IDLE
	var command = _command_queue[0] as PlayerCommand
	
	return command.state == player_state
	


func _cast_attack_on_entity(attack, entity, target) -> void:
	look_at(entity.global_transform.origin, Vector3.UP)
	
	# Check if target is in range, if its not, then do nothing.
	
	var msg = UseAttackMessage.new()
	msg.player_attack_id = attack
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)
	
	_command_queue.clear()


func _check_queued_actions() -> void:
	if _is_in_state(PlayerState.IDLE):
		return
	var cmd = _command_queue[0] as PlayerCommand
	if _is_in_state(PlayerState.ATTACKING):
		var target_entity = cmd.target_entity
		_attack(target_entity)
	elif _is_in_state(PlayerState.USE):
		var target_entity = cmd.target_entity
		if target_entity != null:
			_use(target_entity)


func _clear_queued_actions() -> void:
	_command_queue.clear()


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _terrain_clicked(global_pos: Vector3) -> void:
	# We ignore movement clicks if we are currently constructing
	if _is_in_state(PlayerState.CONSTRUCTING):
		return
	
	# We also ignore movement clicks when we are marked as non movable
	if _entity.get_component(NoMovementComponent.NAME) != null:
		return
	
	_play_move_marker(global_pos)
	# We cancel all queued actions
	_clear_queued_actions()
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
	_command_queue.push_front(cmd)
	
	_model.transition_to(Mannequiny.States.RUN)


func _play_move_marker(position: Vector3) -> void:
	_move_cursor.global_transform.origin = position
	_move_cursor.play()


func _on_player_interact(target_entity: Entity, type: String) -> void:
	if type == "basic_attack":
		_attack(target_entity)
	elif type == "use":
		_use(target_entity)


func _use(target_entity: Entity) -> void:
	# Check if we are in usable range.
	# Yes, use item -> call use on structure.
	# No, try to close distance and re-check usability
	var target_origin = target_entity.get_spatial().global_transform.origin
	var target_distance = target_origin.distance_to(global_transform.origin)
	
	var in_use_range = false
	if  in_use_range:
		# todo
		return
	else:
		var use_cmd = PlayerCommand.new()
		use_cmd.state = PlayerState.USE
		use_cmd.target_entity = target_entity
		_command_queue.push_front(use_cmd)
		
		_move_to_distance_from_entity(0.1, target_entity)


func _attack(target_entity: Entity) -> void:
	if _has_attack_delay:
		return
	
	var target_origin = target_entity.get_spatial().global_transform.origin
	look_at(target_origin, Vector3.UP)
	
	# Check if in range, if not walk to target
	var weapon_comp = _entity.get_component(WeaponComponent.NAME) as WeaponComponent
	if weapon_comp == null:
		print_debug("No weapon component on player entity")
		return
	
	var atk_cmd = PlayerCommand.new()
	atk_cmd.state = PlayerState.ATTACKING
	atk_cmd.target_entity = target_entity
	_command_queue.push_front(atk_cmd)
	
	# Check if we need to move towards our target before we can perform the attack
	var target_distance = target_origin.distance_to(global_transform.origin)
	if  weapon_comp.attack_range < target_distance:
		_move_to_distance_from_entity(weapon_comp.attack_range, target_entity)
		return
	
	# TODO diffeentiate between melee or ranged depending on equip component
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onMessageSend", atk_msg)

	_has_attack_delay = true
	_attack_delay.wait_time = weapon_comp.attack_delay
	_attack_delay.start()


func _move_to_distance_from_entity(distance: float, target_entity: Entity) -> void:
	# We want to keep some safety margin for rounding errors.
	distance -= 0.5
	var target_origin = target_entity.get_spatial().global_transform.origin
	var offset_vec = (target_origin - global_transform.origin).normalized() * distance
	var target = target_origin - offset_vec
	_move_to(target)


func _on_AttackDelay_timeout():
	_has_attack_delay = false
	
	if _is_in_state(PlayerState.ATTACKING):
		var cmd = _command_queue[0]
		if cmd.target_entity == null:
			_clear_queued_actions()
		else:
			_attack(cmd.target_entity)
