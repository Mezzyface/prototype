# resources/EvolutionRequirement.gd
extends Resource
class_name EvolutionRequirement

@export var target_creature_id: String = ""
@export var evolution_name: String = ""
@export var requirements: Array[RequirementCondition] = []

func check_requirements(creature: Creature) -> bool:
	for req in requirements:
		if not req.is_met(creature):
			return false
	return true

func get_progress(creature: Creature) -> float:
	if requirements.is_empty():
		return 0.0
	
	var min_progress = 1.0
	for req in requirements:
		min_progress = min(min_progress, req.get_progress(creature))
	return min_progress

func get_description() -> String:
	var parts = []
	for req in requirements:
		parts.append(req.get_description())
	return " AND ".join(parts)
