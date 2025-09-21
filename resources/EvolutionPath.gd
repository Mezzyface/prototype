extends Resource
class_name EvolutionPath

@export var target_creature_scene: PackedScene
@export var evolution_name: String = ""
@export var requirement_type: Enums.RequirementType = Enums.RequirementType.CLICKS
@export var requirement_value: int = 10
@export var required_item: Enums.ItemID = Enums.ItemID.NONE
