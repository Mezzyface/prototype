# resources/CreatureDatabase.gd
extends Resource
class_name CreatureDatabase

@export var creatures: Array[CreatureDefinition] = []

var _creature_lookup: Dictionary = {}

func _init():
	refresh_lookup()

func refresh_lookup():
	_creature_lookup.clear()
	for creature_def in creatures:
		if creature_def and not creature_def.creature_id.is_empty():
			_creature_lookup[creature_def.creature_id] = creature_def

func get_creature(id: String) -> CreatureDefinition:
	return _creature_lookup.get(id)

func validate_all() -> bool:
	var valid = true
	for creature_def in creatures:
		if not creature_def.validate():
			valid = false
	return valid
