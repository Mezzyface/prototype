# resources/CreatureDefinition.gd
extends Resource
class_name CreatureDefinition

@export var creature_id: String = ""
@export var display_name: String = ""
@export var stage: Enums.CreatureStage = Enums.CreatureStage.BABY

# Visual data
@export var sprite_resource: SpriteFrames
@export var collision_radius: float = 10.0
@export var sprite_offset: Vector2 = Vector2(0, -16)

# Stats
@export var base_speed: float = 50.0
@export var can_seek_items: bool = true

# Evolution options
@export var evolutions: Array[EvolutionRequirement] = []

func validate() -> bool:
	if creature_id.is_empty():
		push_error("Creature ID is empty for " + display_name)
		return false
	if not sprite_resource:
		push_error("No sprite resource for " + creature_id)
		return false
	return true
