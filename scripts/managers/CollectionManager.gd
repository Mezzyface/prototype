extends Node
class_name CollectionManager

signal creature_discovered(creature_id: String)
signal collection_updated

var discovered_creatures: Dictionary = {}  # id: discovery_data
var total_creatures: int = 0  # Total possible creatures
var creature_database: CreatureDatabase

func _ready():
	creature_database = preload("res://resources/creature_database.tres")
	total_creatures = creature_database.creatures.size()
	
	print("Collection Manager ready!")
	print("Discovered: %d/%d" % [discovered_creatures.size(), total_creatures])

func register_creature(creature_id: String):
	if creature_id in discovered_creatures:
		print("Already discovered: ", creature_id)
		return false
		
	# New discovery!
	discovered_creatures[creature_id] = {
		"timestamp": Time.get_ticks_msec(),
		"count": 1
	}
	
	print("NEW DISCOVERY: ", creature_id)
	creature_discovered.emit(creature_id)
	collection_updated.emit()
	return true

func get_discovery_count() -> int:
	return discovered_creatures.size()

func get_completion_percentage() -> float:
	return float(discovered_creatures.size()) / float(total_creatures) * 100.0

func is_discovered(creature_id: String) -> bool:
	return creature_id in discovered_creatures
	
func connect_gallery(gallery: CollectionGallery):
	collection_updated.connect(gallery._on_collection_updated)
	pass
