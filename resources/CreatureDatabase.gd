# resources/CreatureDatabase.gd
extends Resource
class_name CreatureDatabase

@export var creatures: Array[CreatureDefinition] = []

var _creature_lookup: Dictionary = {}
var _lookup_initialized: bool = false

func _init():
	refresh_lookup()

func refresh_lookup():
	_creature_lookup.clear()
	_lookup_initialized = true
	for creature_def in creatures:
		if creature_def and not creature_def.creature_id.is_empty():
			_creature_lookup[creature_def.creature_id] = creature_def
			print("Added to lookup: ", creature_def.creature_id)  # Debug

func get_creature(id: String) -> CreatureDefinition:
	# Ensure lookup is initialized before accessing
	if not _lookup_initialized or _creature_lookup.is_empty():
		refresh_lookup()
	
	var result = _creature_lookup.get(id)
	if not result:
		print("Available creatures in database: ", _creature_lookup.keys())  # Debug
	return result

func validate_all() -> bool:
	# Refresh before validating
	if not _lookup_initialized:
		refresh_lookup()
		
	var valid = true
	for creature_def in creatures:
		if not creature_def.validate():
			valid = false
	return valid
