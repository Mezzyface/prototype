extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var particles = $GPUParticles2D

# Add export for creature scene
@export var creature_scene: PackedScene

# Add these variables
var current_clicks: int = 0
var clicks_to_hatch: int = 5
var is_Shaking: bool =  false
var is_Hatching: bool= false

# Add signal
signal creature_spawned(creature)

func _ready():
	print("Egg is ready!")
	animated_sprite.play("idle")
	
	# Connect the input event
	input_event.connect(_on_input_event)
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		current_clicks += 1
		print("Clicks: ", current_clicks, "/", clicks_to_hatch)
		
		# Add shake effect
		if !is_Shaking and !is_Hatching:
			is_Shaking = true
			_shake_egg()
			#notShaking = true 
		
		if current_clicks >= clicks_to_hatch and !is_Hatching:
			_start_hatching()

# New function for shake
func _shake_egg():
	
	var tween = get_tree().create_tween()
	var original_pos = animated_sprite.position
	# Quick shake
	tween.tween_property(animated_sprite, "position", original_pos + Vector2(5, 0), 0.08)
	tween.tween_property(animated_sprite, "position", original_pos + Vector2(-5, 0), 0.08)
	tween.tween_property(animated_sprite, "position", original_pos, 0.08)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished(): 
	is_Shaking = false
	
func _start_hatching():
	is_Hatching = true
	print("Starting to Hatch!")
	animated_sprite.play("cracking")

func _on_animation_finished():
	print("Animation finished: ", animated_sprite.animation)
	
	if animated_sprite.animation == "cracking":
		animated_sprite.play("hatching")
		particles.emitting = true  # Start particles!
	elif animated_sprite.animation == "hatching":
		print("Hatching complete!")
		_spawn_creature()
		
func _spawn_creature():
	if not creature_scene:
		print("Warning: No creature scene assigned!")
		queue_free()
		return

	# Create the creature
	var creature = creature_scene.instantiate()
	get_parent().add_child(creature)
	creature.global_position = global_position

	# Simple spawn animation
	creature.scale = Vector2.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(creature, "scale", Vector2.ONE, 0.3)

	# Emit signal
	creature_spawned.emit(creature)
	
	# Remove egg after delay
	await get_tree().create_timer(.5).timeout
	queue_free()
