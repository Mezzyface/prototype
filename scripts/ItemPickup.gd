extends Area2D
class_name ItemPickup

@export var item_data: ItemData
@onready var sprite: Sprite2D = $Sprite2D

var is_collected: bool = false

func _ready():
	# Set the icon from item data
	if item_data and sprite:
		sprite.texture = item_data.icon
		print("Item spawned: ", item_data.display_name)
	
	# Connect to detect when creatures enter
	body_entered.connect(_on_body_entered)
	
	# Add a simple floating animation
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", -5, 1.0)
	tween.tween_property(sprite, "position:y", 0, 1.0)

func _on_body_entered(body):
	if is_collected:
		return
		
	if body is Creature:
		print("Creature touched item!")
		collect(body)

func collect(creature: Creature):
	is_collected = true
	creature.add_item(item_data)  # Give to creature

	# Simple disappear effect
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(.5, .5), 0.2)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
