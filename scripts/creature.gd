extends CharacterBody2D
class_name Creature

@onready var sprite = $AnimatedSprite2D
@onready var click_area = $Area2D

@export var evolutionData: EvolutionData
@export var can_evolve: bool = false

# Basic info
var creature_name: String = ""

# Evolution tracking
var clicks_received: int = 0
var time_alive: float = 0.0

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
