extends Node
class_name CritterGameCoordinator

# This coordinator belongs to the Critter Collector game only
# Acts as a local signal hub without being an autoload

signal creature_spawned(creature: Creature)
signal creature_clicked(creature: Creature)
signal creature_evolved(old_creature: Creature, new_creature: Creature)
signal creature_discovered(creature_id: String, first_time: bool)
signal creature_ready_to_evolve(creature: Creature, path: EvolutionPath)
signal item_collected(item: ItemData, creature: Creature)
signal item_spawned(item: ItemPickup)
signal reset_requested()

# References to all game systems
var collection_manager: CollectionManager
var evolution_manager: EvolutionManager
var creature_spawner: CreatureSpawner
var item_spawner: ItemSpawner
var current_creature: Creature

func setup_systems(tile_map: TileMapLayer, boat: Boat):
	# Create and configure all systems
	collection_manager = CollectionManager.new()
	evolution_manager = EvolutionManager.new()
	creature_spawner = CreatureSpawner.new()
	item_spawner = ItemSpawner.new()
	
	add_child(collection_manager)
	add_child(evolution_manager)
	add_child(creature_spawner)
	add_child(item_spawner)
	
	creature_spawner.setup(tile_map, boat)
	item_spawner.setup(tile_map)
	
	# Connect internal signals
	_connect_internal_signals()

func _connect_internal_signals():
	# Systems talk to each other through the coordinator
	creature_spawner.creature_spawned.connect(_on_creature_spawned)
	item_spawner.item_spawned.connect(func(item): item_spawned.emit(item))
	evolution_manager.evolution_completed.connect(_on_evolution_completed)

func _on_creature_spawned(creature: Creature):
	current_creature = creature

	# Disconnect any previous creature signals if they exist
	if creature.ready_to_evolve.is_connected(_on_creature_ready_to_evolve):
		creature.ready_to_evolve.disconnect(_on_creature_ready_to_evolve)
	
	# Connect new creature signals
	creature.ready_to_evolve.connect(_on_creature_ready_to_evolve)
	creature.clicked.connect(func(c): creature_clicked.emit(c))
	
	# Emit that a creature was spawned
	creature_spawned.emit(creature)

func _on_creature_ready_to_evolve(creature: Creature, path: EvolutionPath):
	print("Coordinator: Creature ready to evolve!")
	
	# Prevent the spam by disabling evolution checks immediately
	#creature.can_evolve = false
	
	creature_ready_to_evolve.emit(creature, path)
	evolution_manager.trigger_evolution(creature, path)

func _on_evolution_completed(old_creature: Creature, new_creature: Creature):
	print("Coordinator: Evolution completed!")
	current_creature = new_creature
	
	# Connect the new creature's signals
	_on_creature_spawned(new_creature)  # Reuse the spawn handler for connections
	
	creature_evolved.emit(old_creature, new_creature)

func register_discovery(creature: Creature) -> bool:
	var was_new = collection_manager.register_creature(creature.evolutionData.creature_id)
	if was_new:
		creature_discovered.emit(creature.evolutionData.creature_id, true)
	return was_new

func cleanup_current_creature():
	if current_creature and is_instance_valid(current_creature):
		if current_creature.ready_to_evolve.is_connected(_on_creature_ready_to_evolve):
			current_creature.ready_to_evolve.disconnect(_on_creature_ready_to_evolve)
		current_creature.queue_free()
		current_creature = null
