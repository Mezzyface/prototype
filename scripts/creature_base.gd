extends CharacterBody2D
class_name Creature

@onready var sprite = $AnimatedSprite2D
@onready var click_area = $Area2D

# Basic info
@export var creature_name: String = "Baby Creature"
var evolution_stage: int = 0

# Evolution tracking
var clicks_received: int = 0
var time_alive: float = 0.0
@export var clicks_to_evolve: int = 10
@export var can_evolve: bool = true

# Evolution scenes
@export_group("Evolution Paths")
@export var evolution_scene: PackedScene

signal clicked(creature)
signal ready_to_evolve

func _ready():
	print("Creature spawned: ", creature_name)
	sprite.play("idle")
	# Connect click detection
	click_area.input_event.connect(_on_input_event)

func _process(delta):
	if can_evolve:
		time_alive += delta

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		_handle_click()

func _handle_click():
	clicks_received += 1
	clicked.emit(self)
	
	print("%s clicked! (%d/%d)" % [creature_name, clicks_received, clicks_to_evolve])
	
	# Visual feedback
	_show_click_feedback()
	
	var texture = get_evolution_preview()
	if texture:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.position = Vector2(100, 100)  # Set position
		sprite.modulate = Color.BLACK
		add_child(sprite)

	# Check evolution
	if can_evolve and clicks_received >= clicks_to_evolve:
		_show_evolution_ready()
		ready_to_evolve.emit()

func _show_click_feedback():
	# Simple scale pop
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)

func _show_evolution_ready():
	# Glow effect
	sprite.modulate = Color(1.2, 1.2, 0.8)
	
	# Optional: Add pulsing
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.95, 0.95), 0.5)
	
# Show what creature will evolve into
func get_evolution_preview() -> Texture2D:
	if not evolution_scene:
		return null
		
	# Load the scene and get its sprite
	var preview = evolution_scene.instantiate()
	var preview_sprite = preview.get_node("AnimatedSprite2D")
	var texture = preview_sprite.sprite_frames.get_frame_texture("idle", 0)
	preview.queue_free()
	
	
	return texture
