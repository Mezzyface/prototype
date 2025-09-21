extends Node
class_name CritterGameCoordinator

# This coordinator belongs to the Critter Collector game only
# Acts as a local signal hub without being an autoload

signal creature_spawned(creature: Creature)
signal creature_clicked(creature: Creature)
signal creature_evolved(old_creature: Creature, new_creature: Creature)
signal creature_discovered(creature_id: String, first_time: bool)
signal creature_ready_to_evolve(creature: Creature, evolution_req: EvolutionRequirement)
signal item_collected(item: ItemData, creature: Creature)
signal item_spawned(item: ItemPickup)
signal reset_requested()

# References to all game systems
var collection_manager: CollectionManager
var evolution_manager: EvolutionManager
var creature_spawner: CreatureSpawner
var item_spawner: ItemSpawner
var creature_factory: CreatureFactory 
var current_creature: Creature
var evolution_check_timer: Timer
var check_evolution_on_next_frame: bool = false

func setup_systems(tile_map: TileMapLayer, boat: Boat):
	creature_factory = CreatureFactory.new()
	creature_factory.creature_database = preload("res://resources/creature_database.tres")
	add_child(creature_factory)

	# ADD: Create evolution check timer
	evolution_check_timer = Timer.new()
	evolution_check_timer.wait_time = 1.0  # Check every second instead of every frame
	evolution_check_timer.timeout.connect(_periodic_evolution_check)
	add_child(evolution_check_timer)
	
	# Create and configure all systems
	collection_manager = CollectionManager.new()
	evolution_manager = EvolutionManager.new()
	creature_spawner = CreatureSpawner.new()
	item_spawner = ItemSpawner.new()
	
	add_child(collection_manager)
	add_child(evolution_manager)
	add_child(creature_spawner)
	add_child(item_spawner)
	
	creature_spawner.setup(tile_map, boat, creature_factory)
	evolution_manager.setup(creature_factory)
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

	# Just connect the clicked signal
	creature.clicked.connect(func(c): 
		creature_clicked.emit(c)
		_on_creature_action_taken()  # Check evolution after clicks
	)

	if creature.has_signal("item_collected"):
		creature.item_collected.connect(func(c):
			_on_creature_action_taken()  # Check evolution after item collection
		)

	# Start checking for evolution if this creature can evolve
	if creature.can_evolve:
		evolution_check_timer.start()
	else:
		evolution_check_timer.stop()

	creature_spawned.emit(creature)

# ADD: Called after any action that might trigger evolution
func _on_creature_action_taken():
	"""Called after clicks, item collection, etc."""
	if current_creature and current_creature.can_evolve:
		check_evolution_on_next_frame = true

func _process(_delta):
	if check_evolution_on_next_frame:
		check_evolution_on_next_frame = false
		_check_for_evolution()

# ADD: Periodic check (every second instead of every frame)
func _periodic_evolution_check():
	_check_for_evolution()

func _check_for_evolution():
	"""Check if current creature can evolve"""
	if not current_creature or not is_instance_valid(current_creature):
		return
		
	if not current_creature.can_evolve:
		return
	
	# Get available evolutions from creature
	var available_evolutions = current_creature.get_available_evolutions()
	
	if available_evolutions.is_empty():
		return
	
	# We have an evolution available!
	print("Evolution available for %s" % current_creature.creature_name)
	
	# Stop checking to prevent spam
	current_creature.can_evolve = false
	evolution_check_timer.stop()
	
	# Use the first available evolution (you could add choice UI here later)
	var chosen_evolution = available_evolutions[0]
	
	# Emit signal and trigger evolution
	creature_ready_to_evolve.emit(current_creature, chosen_evolution)
	evolution_manager.trigger_evolution(current_creature, chosen_evolution)

func _on_creature_ready_to_evolve(creature: Creature, evolution_req: EvolutionRequirement):
	print("Coordinator: Creature ready to evolve!")
	
	# Prevent the spam by disabling evolution checks immediately
	#creature.can_evolve = false
	
	creature_ready_to_evolve.emit(creature, evolution_req)
	evolution_manager.trigger_evolution(creature, evolution_req)

func _on_evolution_completed(old_creature: Creature, new_creature: Creature):
	print("Coordinator: Evolution completed!")
	
	# Stop the evolution timer (in case it's still running)
	evolution_check_timer.stop()
	
	current_creature = new_creature
	
	# Connect the new creature's signals
	_on_creature_spawned(new_creature)
	
	creature_evolved.emit(old_creature, new_creature)
	
func register_discovery(creature: Creature) -> bool:
	var creature_id = creature.creature_id
	if creature_id.is_empty():
		push_error("Creature has no ID!")
		return false
		
	var was_new = collection_manager.register_creature(creature_id)
	if was_new:
		creature_discovered.emit(creature_id, true)
	return was_new

func cleanup_current_creature():
	if current_creature and is_instance_valid(current_creature):
		if current_creature.ready_to_evolve.is_connected(_on_creature_ready_to_evolve):
			current_creature.ready_to_evolve.disconnect(_on_creature_ready_to_evolve)
		current_creature.queue_free()
		current_creature = null
