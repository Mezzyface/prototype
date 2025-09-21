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
	CLICKING
}

# Movement component states (from CreatureMovement.gd if you made it)
enum MovementState {
	IDLE,
	MOVING
}

# Creature stages (from EvolutionData.gd comment: 0=baby, 1=teen, 2=adult)
enum CreatureStage {
	EGG,
	BABY,
	KID,
	TEEN,
	ADULT
}
