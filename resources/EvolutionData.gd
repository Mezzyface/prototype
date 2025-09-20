extends Resource
class_name EvolutionData

@export var creature_id: String = ""
@export var display_name: String = ""
@export var stage: int = 0  # 0=baby, 1=teen, 2=adult

# Evolution options
@export var possible_evolutions: Array[EvolutionPath] = []
