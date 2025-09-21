class_name Enums
extends Resource

# Evolution requirement types (replacing the string-based system)
enum RequirementType {
	CLICKS,
	TIME,
	ITEM
}

# Creature movement states (from creature.gd)
enum CreatureState {
	IDLE,
	MOVING,
	CLICKING,
	SEEKING_ITEM  # NEW: When actively moving toward an item
}

# Movement component states (from CreatureMovement.gd if you made it)
enum MovementState {
	IDLE,
	MOVING,
	SEEKING  # NEW: Alternative for item seeking
}

# Creature stages (from EvolutionData.gd comment: 0=baby, 1=teen, 2=adult)
enum CreatureStage {
	EGG,
	BABY,
	KID,
	TEEN,
	ADULT
}

# NEW: Item rarity levels
enum ItemRarity {
	COMMON,
	RARE,
	LEGENDARY
}

# NEW: Item types (for different behaviors)
enum ItemType {
	CONSUMABLE,   # Used up when collected
	PERMANENT,    # Stays in inventory
	EVOLUTION     # Specifically for evolution
}
