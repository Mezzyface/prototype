# resources/RequirementCondition.gd
extends Resource
class_name RequirementCondition

@export var type: Enums.RequirementType = Enums.RequirementType.CLICKS
@export var value: int = 10
@export var item_id: Enums.ItemID = Enums.ItemID.NONE

func is_met(creature: Creature) -> bool:
	match type:
		Enums.RequirementType.CLICKS:
			return creature.clicks_received >= value
		Enums.RequirementType.TIME:
			return creature.time_alive >= value
		Enums.RequirementType.ITEM:
			var item_count = creature.inventory.get(item_id, 0)
			return item_count >= value
	return false

func get_progress(creature: Creature) -> float:
	match type:
		Enums.RequirementType.CLICKS:
			return float(creature.clicks_received) / float(value)
		Enums.RequirementType.TIME:
			return creature.time_alive / float(value)
		Enums.RequirementType.ITEM:
			var item_count = creature.inventory.get(item_id, 0)
			return float(item_count) / float(value)
	return 0.0

func get_description() -> String:
	match type:
		Enums.RequirementType.CLICKS:
			return "%d clicks" % value
		Enums.RequirementType.TIME:
			return "%.1f seconds" % value
		Enums.RequirementType.ITEM:
			var item_name = Enums.ItemID.keys()[item_id]
			return "%d %s" % [value, item_name]
	return ""
