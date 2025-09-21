extends CharacterBody2D
class_name Creature

@onready var sprite = $AnimatedSprite2D
@onready var click_area = $Area2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@export var evolutionData: EvolutionData
@export var can_evolve: bool = false

# Components
var movement: CreatureMovement

# Basic info
var creature_name: String = ""

# Evolution tracking

var clicks_received: int = 0
var time_alive: float = 0.0

# Clicking state
var is_being_clicked: bool = false

# Reference to main scene (for tile checking if needed)
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
	
	# Ensure NavigationAgent2D exists
	if not has_node("NavigationAgent2D"):
		navigation_agent = NavigationAgent2D.new()
		add_child(navigation_agent)
		print("Added NavigationAgent2D to ", creature_name)
	
	# Setup movement component
	if creature_name != "Lil_Egg":
		movement = CreatureMovement.new()
		add_child(movement)
		movement.setup(self, navigation_agent, sprite)
	
	# Connect click detection
	click_area.input_event.connect(_on_input_event)

func _process(delta):
	time_alive += delta
	
	# Let movement component handle movement unless being clicked
	if not is_being_clicked and movement:
		movement.process_movement(delta)
	
	if can_evolve:
		evolutionCheck()

func _physics_process(delta):
	# Let movement component handle physics
	if not is_being_clicked and movement:
		movement.physics_process_movement(delta)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		_handle_click()

func _handle_click():
	is_being_clicked = true
	if movement:
		movement.stop_movement()
	
	clicks_received += 1
	clicked.emit(self)
	
	print("%s clicked! (%d)" % [creature_name, clicks_received])
	_show_click_feedback()
	
	# Resume movement after click
	await get_tree().create_timer(0.5).timeout
	is_being_clicked = false
	
	if can_evolve:
		evolutionCheck()

func _show_click_feedback():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)

func evolutionCheck():
	if not can_evolve or not evolutionData:
		return
	
	for path in evolutionData.possible_evolutions:
		match path.requirement_type:
			Enums.RequirementType.CLICKS:
				if clicks_received >= path.requirement_value:
					ready_to_evolve.emit(self, path)
			Enums.RequirementType.TIME:
				if time_alive >= path.requirement_value:
					ready_to_evolve.emit(self, path)
			Enums.RequirementType.ITEM:
				# TODO: Implement item checking
				pass

func prepare_for_evolution():
	# Stop and remove movement component
	if movement:
		movement.stop_movement()
		movement.queue_free()
		movement = null
	
	# Stop processing
	set_process(false)
	set_physics_process(false)
	
	# Ensure we're in idle animation
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
		
# Configure movement for display creatures
func configure_as_display(center: Vector2, radius: float = 100.0):
	can_evolve = false
	if movement:
		movement.set_constraint(center, radius)
		movement.move_speed = 30.0  # Slower for display
