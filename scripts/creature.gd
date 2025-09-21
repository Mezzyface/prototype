extends CharacterBody2D
class_name Creature

@onready var sprite = $AnimatedSprite2D
@onready var click_area = $Area2D
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

@export var evolutionData: EvolutionData
@export var can_evolve: bool = false

enum State {IDLE, MOVING, CLICKING}

# Basic info
var current_state: State = State.IDLE
var creature_name: String = ""

# Movement variables
var move_speed: float = 50.0
var target_position: Vector2
var idle_timer: float = 0.0
var idle_duration: float = 2.0  # How long to stay idle

# Evolution tracking
var clicks_received: int = 0
var time_alive: float = 0.0

var main_scene

# Signals
signal clicked(creature)
signal ready_to_evolve(creature, path)

func _ready():
	print("Creature spawned: ", creature_name)
	if evolutionData:
		creature_name = evolutionData.display_name
	else:
		push_error("No evolution data assigned to creature!")
		creature_name = "Unknown"

	sprite.play("idle")
	# Connect click detection
	click_area.input_event.connect(_on_input_event)
	

func _process(delta):
	
	# Handle movement states
	match current_state:
		State.IDLE:
			_handle_idle(delta)
		State.MOVING:
			_handle_moving(delta)
		State.CLICKING:
			pass  # Do nothing while being clicked
			
	time_alive += delta

	if can_evolve:
		evolutionCheck()
	
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		_handle_click()

func _handle_click():
	clicks_received += 1
	clicked.emit(self)
	
	print("%s clicked! (%d)" % [creature_name, clicks_received])
	
	# Visual feedback
	_show_click_feedback()

	# Check evolution
	if can_evolve:
		evolutionCheck()

func _show_click_feedback():
	# Simple scale pop
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)

func evolutionCheck():
	if can_evolve:
		for path in evolutionData.possible_evolutions:
			match path.requirement_type:
				"clicks":
					if clicks_received >= path.requirement_value:
						ready_to_evolve.emit(self, path)

func _handle_idle(delta):
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	idle_timer += delta
	if idle_timer >= idle_duration:
		# Time to move somewhere!
		_pick_random_destination()
		idle_timer = 0.0
		idle_duration = randf_range(1.0, 3.0)  # Randomize next idle time

func _handle_moving(delta):
	if sprite.sprite_frames.has_animation("walking"):
		sprite.play("walking")
		var direction = (target_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		
		# Check if we reached the target
		if global_position.distance_to(target_position) < 10:
			current_state = State.IDLE
			velocity = Vector2.ZERO

func _pick_random_destination():
	if not main_scene:
		return

	# Try to find a valid position
	var max_attempts = 10
	for i in max_attempts:
		# Pick a random offset
		var offset = Vector2(
			randf_range(-100, 100),
			randf_range(-100, 100)
		)
		var test_pos = global_position + offset

		# Check if it's walkable
		if main_scene.is_position_walkable(test_pos):
			target_position = test_pos
			current_state = State.MOVING
			return

	# Couldn't find a valid position, stay idle
	print("No valid position found")
