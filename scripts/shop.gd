extends Area2D
class_name Shop

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var item_label: Label = $ItemLabel
@onready var item_preview: Sprite2D = $ItemPreview 

# Item spawning
@export var spawn_offset: Vector2 = Vector2(50, 20)  # Where items appear relative to shop
@export var spawn_cooldown: float = 2.0
@export var spawn_coords: Vector2 = Vector2(1,1)
var can_spawn: bool = true

# Visual feedback
var is_hovering: bool = false

# Item selection
var available_items: Array[String] = ["apple", "honey", "beer"]
var current_item_index: int = 0

# Signals
signal item_spawn_requested(item_type: String, position: Vector2)

func _ready():
	# Play idle animation
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Connect input detection
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Make sure shop is clickable
	input_pickable = true

	# Update initial display
	_update_item_display()
	
	print("shop ready to spawn items!")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and can_spawn:
			_handle_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cycle_item()

func _handle_click():
	if not can_spawn:
		return
	
	print("shop clicked! Spawning item...")
	
	# Prevent spam
	can_spawn = false
	sprite.modulate = Color(0.7, 0.7, 0.7)  # Gray out during cooldown
	
	# Visual feedback - shop bounces
	_play_spawn_animation()
	
	# Calculate spawn position
	var spawn_pos = spawn_coords
	
	# Emit signal for main scene to handle actual spawning
	item_spawn_requested.emit(available_items[current_item_index], spawn_pos)
	
	# Re-enable after cooldown
	await get_tree().create_timer(spawn_cooldown).timeout
	can_spawn = true
	sprite.modulate = Color.WHITE

func _cycle_item():
	# Cycle to next item
	current_item_index = (current_item_index + 1) % available_items.size()
	_update_item_display()
	
	# Visual feedback for cycling
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "rotation_degrees", 360, 0.3)
	tween.tween_callback(func(): sprite.rotation_degrees = 0)
	
	print("Switched to: ", available_items[current_item_index])

func _update_item_display():
	if item_label:
		var current_item = available_items[current_item_index]
		item_label.text = _get_item_display_name(current_item)
		
		# Color code the label based on item
		match current_item:
			"apple":
				item_label.modulate = Color(1, 0.3, 0.3)
			"honey":
				item_label.modulate = Color(1, 0.5, 1)
			"beer":
				item_label.modulate = Color(0.5, 1, 0.5)
	_update_item_preview()

func _get_item_display_name(item_key: String) -> String:
	match item_key:
		"apple":
			return "Apple"
		"honey":
			return "Honey"
		"beer":
			return "Beer"
		_:
			return item_key

func _play_spawn_animation():
	var tween = get_tree().create_tween()
	
	# shop jumps up and down
	tween.tween_property(sprite, "position:y", -10, 0.1)
	tween.tween_property(sprite, "position:y", 0, 0.1)
	
	# Little squash and stretch
	tween.parallel().tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _on_mouse_entered():
	is_hovering = true
	_update_hover_state()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	# Show tooltip
	if item_label:
		item_label.visible = true

func _on_mouse_exited():
	is_hovering = false
	sprite.modulate = Color.WHITE if can_spawn else Color(0.7, 0.7, 0.7)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	# Hide tooltip after a moment
	if item_label:
		await get_tree().create_timer(0.5).timeout
		if not is_hovering:  # Only hide if still not hovering
			item_label.visible = false

func _update_hover_state():
	if is_hovering and can_spawn:
		sprite.modulate = Color(1.2, 1.2, 1.2)

func _unhandled_input(event):
	# Allow keyboard cycling when hovering
	if is_hovering and event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			_cycle_item()

func _update_item_preview():
	if not item_preview:
		return
		
	# Load the item's icon texture
	var current_item = available_items[current_item_index]
	match current_item:
		"apple":
			# Use your apple texture
			item_preview.texture = preload("res://assets/items/rpg_item_icon_apple_44.png")
		"honey":
			# Use candy texture once you have it
			item_preview.texture = preload("res://assets/items/rpg_item_icon_honey_63.png")
		"beer":
			# Use stone texture once you have it  
			item_preview.texture = preload("res://assets/items/rpg_item_icon_beer_56.png")

	# Scale it down to icon size
	item_preview.scale = Vector2(0.052, 0.052)

	# Make it bounce gently
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(item_preview, "position:y", -5, 1.0)
	tween.tween_property(item_preview, "position:y", 0, 1.0)
