extends Control
class_name CollectionGallery

@onready var grid = $VBoxContainer/ScrollContainer/GridContainer
@onready var progress_label = $VBoxContainer/Label
@onready var close_button = $CloseButton

@export var creature_card_scene: PackedScene

# List of all possible creatures
var all_creatures = [
	"Baby Dragon", "Teen Dragon", "Adult Dragon",
	"Baby Bird", "Teen Bird", "Phoenix",
	"Baby Slime", "Teen Slime", "King Slime",
	# Add more...
]

func _ready():
	close_button.pressed.connect(hide)

func _populate_gallery(collectionManager: CollectionManager):
	print("Gallery visibility: ", visible)
	print("Grid node exists: ", grid != null)
	if grid:
		print("Grid size: ", grid.size)
	# Clear existing
	for child in grid.get_children():
		child.queue_free()
	
	# Create card for each possible creature
	for creature_id in all_creatures:
		print("setting up:", creature_id)
		var card = creature_card_scene.instantiate()
		grid.add_child(card)
		
		var discovered = collectionManager.is_discovered(creature_id)
		card.setup(creature_id, discovered)

func _update_progress(collectionManager: CollectionManager):
	var discovered = collectionManager.get_discovery_count()
	var total = collectionManager.total_creatures
	var percentage = collectionManager.get_completion_percentage()
	
	progress_label.text = "%d/%d Discovered (%.0f%%)" % [discovered, total, percentage]

func _on_collection_updated(collectionManager: CollectionManager):
	_populate_gallery(collectionManager)
	_update_progress(collectionManager)
