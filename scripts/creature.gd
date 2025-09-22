extends CharacterBody2D
class_name Creature

@onready var sprite = $AnimatedSprite2D
@onready var click_area = $Area2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var creature_id: String = ""  # =
var definition: CreatureDefinition

# Components
var movement: CreatureMovement

# Basic info
var creature_name: String = ""
var creature_stage: Enums.CreatureStage
var base_speed: float
var can_seek_items: bool = false
var can_evolve: bool = false
var target_scale: float = 1.0

# Evolution tracking
var inventory: Dictionary = {}  # item_id -> count
var clicks_received: int = 0
var time_alive: float = 0.0

# Clicking state
var is_being_clicked: bool = false

# Signals
signal clicked(creature)
signal ready_to_evolve(creature, path)
signal item_collected(creature)


func _ready():
	print("Creature spawned: ", creature_name, " Stage: ", definition.stage, " Speed: ", definition.base_speed)
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Ensure NavigationAgent2D exists
	if not has_node("NavigationAgent2D"):
		navigation_agent = NavigationAgent2D.new()
		add_child(navigation_agent)
		print("Added NavigationAgent2D to ", creature_name)
	if definition.base_speed > 0:  # BETTER CHECK - uses speed instead of name
		movement = CreatureMovement.new()
		add_child(movement)
		movement.setup(self, navigation_agent, sprite)
		movement.move_speed = definition.base_speed
		
		# Only seek items if the creature can
		if not definition.can_seek_items:
			movement.item_detection_radius = 0
	
	# Connect click detection
	click_area.input_event.connect(_on_input_event)

func _process(delta):
	time_alive += delta
	
	# Let movement component handle movement unless being clicked
	if not is_being_clicked and movement:
		movement.process_movement(delta)


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

func _show_click_feedback():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)
	
func get_available_evolutions() -> Array:
	"""Check which evolutions are currently available"""
	var available = []
	if not definition or definition.evolutions.is_empty():
		return available
	
	for evolution in definition.evolutions:
		if evolution.check_requirements(self):
			available.append(evolution) 
	
	return available

func add_item(item_data: ItemData):
	var item_id = item_data.item_id
	
	if item_id in inventory:
		inventory[item_id] += 1
	else:
		inventory[item_id] = 1
	
	var item_name = Enums.ItemID.keys()[item_id]
	print("%s collected %s! (Total: %d)" % [creature_name, item_data.display_name, inventory[item_id]])
	
	_show_item_collected_effect()

	item_collected.emit(self)

# Configure movement for display creatures
func configure_as_display(center: Vector2, radius: float = 100.0):
	can_evolve = false
	if movement:
		#movement.set_constraint(center, radius)
		movement.move_speed = 30.0  # Slower for display

func _show_item_collected_effect():
	# Make the creature glow briefly
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
