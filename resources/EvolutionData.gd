extends Resource
class_name EvolutionData

@export var creature_id: String = ""
@export var display_name: String = ""
@export var stage: Enums.CreatureStage = Enums.CreatureStage.BABY  # Changed from int

# Evolution options
@export var possible_evolutions: Array[EvolutionPath] = []
