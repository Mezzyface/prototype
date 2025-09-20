extends Resource
class_name EvolutionPath

@export var target_creature_scene: PackedScene
@export var evolution_name: String = ""
@export var requirement_type: String = "clicks"  # clicks, time, item
@export var requirement_value: int = 10
