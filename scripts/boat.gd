extends Area2D
class_name Boat

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Cooldown to prevent spam clicking
var can_reset: bool = true
var reset_cooldown: float = 1.0

signal reset_requested

func _ready():
	# Play idle animation if you have one
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Connect input detection
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Make sure boat is clickable
	input_pickable = true
	
	# Add gentle bobbing
	_create_bobbing_animation()
	
	print("Boat ready for resets!")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and can_reset:
			_handle_click()

func _handle_click():
	if not can_reset:
		return
		
	print("Boat clicked! Requesting reset...")
	
	# Prevent spam
	can_reset = false
	sprite.modulate = Color(0.7, 0.7, 0.7)  # Gray out during cooldown
	
	# Visual feedback - boat rocks
	_play_click_animation()
	
	# Emit signal for main scene to handle
	reset_requested.emit()
	
	# Re-enable after cooldown
	await get_tree().create_timer(reset_cooldown).timeout
	can_reset = true
	sprite.modulate = Color.WHITE

func _play_click_animation():
	# Rock the boat animation
	var tween = get_tree().create_tween()
	
	# Rock back and forth
	tween.tween_property(sprite, "rotation_degrees", -5, 0.1)
	tween.tween_property(sprite, "rotation_degrees", 5, 0.1)
	tween.tween_property(sprite, "rotation_degrees", -3, 0.1)
	tween.tween_property(sprite, "rotation_degrees", 3, 0.1)
	tween.tween_property(sprite, "rotation_degrees", 0, 0.1)
	
	# Bounce
	tween.parallel().tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _create_bobbing_animation():
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	
	# Gentle up and down
	tween.tween_property(sprite, "position:y", -3, 2.0)
	tween.tween_property(sprite, "position:y", 3, 2.0)

func _on_mouse_entered():
	if can_reset:
		sprite.modulate = Color(1.2, 1.2, 1.2)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	if can_reset:
		sprite.modulate = Color.WHITE
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# Call this when a creature boards the boat
func play_boarding_animation():
	# Extra animation when creature gets on
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
