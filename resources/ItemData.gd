extends Resource
class_name ItemData

@export var item_id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var rarity: Enums.ItemRarity = Enums.ItemRarity.COMMON
@export var item_type: Enums.ItemType = Enums.ItemType.EVOLUTION
@export var stack_size: int = 99  # Max stack size
