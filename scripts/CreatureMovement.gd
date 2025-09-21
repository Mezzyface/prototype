extends Node
class_name CreatureMovement

@export var move_speed: float = 50.0
@export var idle_duration_min: float = 2.0
@export var idle_duration_max: float = 5.0
@export var wander_radius: float = 150.0

# Movement constraint (for island-locked creatures)
@export var use_constraint: bool = false
@export var constraint_center: Vector2
@export var constraint_radius: float = 100.0

# Item seeking
@export var item_detection_radius: float = 200.0  # How far can the creature see?
@export var item_scan_frequency: float = 0.5  # How often to look around (seconds)

# Tracking
var scan_timer: float = 0.0
var target_item: ItemPickup = null

# States - REMOVED local enum, using Enums.MovementState instead
var current_state: Enums.MovementState = Enums.MovementState.IDLE

# References
var creature: CharacterBody2D
var navigation_agent: NavigationAgent2D
var sprite: AnimatedSprite2D

# Timing
var idle_timer: float = 0.0
var current_idle_duration: float = 3.0

func setup(_creature: CharacterBody2D, _nav_agent: NavigationAgent2D, _sprite: AnimatedSprite2D):
	creature = _creature
	navigation_agent = _nav_agent
	sprite = _sprite
	
	if navigation_agent:
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 10.0
		if not navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
			navigation_agent.velocity_computed.connect(_on_velocity_computed)
	
	# Start with random idle
	current_idle_duration = randf_range(idle_duration_min, idle_duration_max)
	
	# Pick initial destination after a short delay
	await creature.get_tree().create_timer(0.5).timeout
	pick_random_destination()

func process_movement(delta: float):
	if not creature or not navigation_agent:
		return

	# Periodically scan for items
	scan_timer += delta
	if scan_timer >= item_scan_frequency:
		scan_timer = 0.0
		_scan_for_items()  # Look around!
	
	if target_item and is_instance_valid(target_item):
		if current_state != Enums.MovementState.SEEKING:
			# Start seeking!
			print("CHANGING STATE TO SEEKING")  # Debug
			current_state = Enums.MovementState.SEEKING
			navigation_agent.target_position = target_item.global_position
			print("Target position set to: ", navigation_agent.target_position)  # Debug

	match current_state:
		Enums.MovementState.IDLE:
			_handle_idle(delta)
		Enums.MovementState.MOVING:
			_handle_moving(delta)
		Enums.MovementState.SEEKING:
			_handle_seeking(delta)

func _scan_for_items():
	if not creature:
		return
	
	# Get all items in the scene
	var items = creature.get_tree().get_nodes_in_group("items")
	
	var closest_item = null
	var closest_distance = item_detection_radius
	
	for item in items:
		if item is ItemPickup and not item.is_collected:
			var distance = creature.global_position.distance_to(item.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_item = item
	
	# If we found something, target it!
	if closest_item and not target_item:
		target_item = closest_item
		print("%s spotted an item!" % creature.creature_name)

func physics_process_movement(_delta: float):
	if not navigation_agent or navigation_agent.is_navigation_finished():
		return
	
	if current_state == Enums.MovementState.MOVING or current_state == Enums.MovementState.SEEKING:
		var next_path_position = navigation_agent.get_next_path_position()
		var direction = creature.global_position.direction_to(next_path_position)
		
		# Calculate velocity
		var new_velocity = direction * move_speed
		
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			creature.velocity = new_velocity
			creature.move_and_slide()

func _handle_idle(delta: float):
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	idle_timer += delta
	if idle_timer >= current_idle_duration:
		pick_random_destination()
		idle_timer = 0.0
		current_idle_duration = randf_range(idle_duration_min, idle_duration_max)

func _handle_moving(_delta: float):
	if sprite and sprite.sprite_frames.has_animation("walking"):
		sprite.play("walking")
	
	if navigation_agent.is_navigation_finished():
		current_state = Enums.MovementState.IDLE
		creature.velocity = Vector2.ZERO

func _handle_seeking(_delta: float):
	# Visual feedback - move faster when excited about items!
	if sprite and sprite.sprite_frames.has_animation("walking"):
		sprite.play("walking")
		sprite.speed_scale = 1.5  # Excited animation!
	
	# Keep updating target position in case item moves
	if target_item and is_instance_valid(target_item):
		navigation_agent.target_position = target_item.global_position
	
	# Check if we reached it or lost it
	if navigation_agent.is_navigation_finished() or not is_instance_valid(target_item):
		target_item = null
		current_state = Enums.MovementState.IDLE
		sprite.speed_scale = 1.0  # Back to normal

func pick_random_destination():
	if not navigation_agent:
		return
	
	var target_position: Vector2
	
	if use_constraint:
		# Stay within constraint area
		var angle = randf() * TAU
		var distance = randf_range(20, constraint_radius)
		target_position = constraint_center + Vector2.from_angle(angle) * distance
	else:
		# Wander freely
		var random_offset = Vector2(
			randf_range(-wander_radius, wander_radius),
			randf_range(-wander_radius, wander_radius)
		)
		target_position = creature.global_position + random_offset
	
	navigation_agent.target_position = target_position
	current_state = Enums.MovementState.MOVING

func _on_velocity_computed(safe_velocity: Vector2):
	creature.velocity = safe_velocity
	creature.move_and_slide()

func stop_movement():
	current_state = Enums.MovementState.IDLE
	idle_timer = 0.0
	if creature:
		creature.velocity = Vector2.ZERO
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func set_constraint(center: Vector2, radius: float):
	use_constraint = true
	constraint_center = center
	constraint_radius = radius
