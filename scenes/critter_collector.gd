extends Node2D

@onready var evolution_manager = EvolutionManager.new()

func _ready():
	add_child(evolution_manager)
	
	# Connect any spawned creatures
	# (You'd do this when egg hatches)
	
func connect_creature(creature: Creature):
	creature.ready_to_evolve.connect(_on_creature_ready.bind(creature))

func _on_creature_ready(creature: Creature):
	print("Main scene: creature ready to evolve!")
	evolution_manager.trigger_evolution(creature)

# Connect this to your egg's creature_spawned signal
func _on_creature_spawned(creature):
	connect_creature(creature)


func _on_egg_creature_spawned(creature: Variant):
	connect_creature(creature)
