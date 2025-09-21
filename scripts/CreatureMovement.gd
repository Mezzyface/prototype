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
	
	match current_state:
		Enums.MovementState.IDLE:
			_handle_idle(delta)
		Enums.MovementState.MOVING:
			_handle_moving(delta)

func physics_process_movement(_delta: float):
	if not navigation_agent or navigation_agent.is_navigation_finished():
		return
	
	if current_state == Enums.MovementState.MOVING:
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
