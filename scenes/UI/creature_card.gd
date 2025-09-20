extends PanelContainer
class_name CreatureCard

@onready var icon = $VBoxContainer/TextureRect
@onready var name_label = $VBoxContainer/Label

var creature_id: String = ""
var is_discovered: bool = false

# Silhouettes for undiscovered
@export var unknown_texture: Texture2D
@export var card_size: Vector2 = Vector2(128, 128)

func setup(id: String, discovered: bool = false):
	creature_id = id
	is_discovered = discovered
	
	custom_minimum_size = card_size
	
	if discovered:
		name_label.text = id
		# TODO: Load actual creature icon
		icon.modulate = Color.WHITE
	else:
		name_label.text = "???"
		icon.texture = unknown_texture
		icon.modulate = Color(0.3, 0.3, 0.3)
		modulate = Color(0.5, 0.5, 0.5)

func _ready():
	print("Inside Card")
	# Add hover effect
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)

func _on_hover_start():
	if is_discovered:
		scale = Vector2(1.05, 1.05)

func _on_hover_end():
	scale = Vector2(1.0, 1.0)
