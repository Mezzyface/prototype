extends Node2D

@onready var game_coordinator = CritterGameCoordinator.new()

#@onready var creature_progress: CreatureProgress = %CreatureProgress
#@onready var collection_gallery: CollectionGallery = $CanvasLayer/CollectionGallery
@onready var label: Label = $CanvasLayer/MarginContainer/Label

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var boat: Boat = $Boat

func _ready():
	add_child(game_coordinator)

	# Let coordinator set up all systems
	game_coordinator.setup_systems(tile_map_layer, boat)
	
	# Connect to coordinator signals for UI updates
	_connect_ui_signals()
	
	# Connect the boat's reset signal
	if boat:
		boat.reset_requested.connect(_on_boat_reset_requested)

	# Initialize game
	_initialize_game()
	
func _connect_ui_signals():
	# Only connect signals that affect UI
	game_coordinator.creature_spawned.connect(_on_creature_spawned_for_ui)
	game_coordinator.creature_evolved.connect(_on_evolution_for_ui)
	game_coordinator.creature_discovered.connect(_on_discovery_for_ui)
	game_coordinator.creature_clicked.connect(_on_creature_clicked_for_ui)

func _initialize_game():
	# Spawn initial creature through coordinator
	game_coordinator.creature_spawner.spawn_egg_at_tile(0, 0)
	
	# Spawn test item
	await get_tree().create_timer(1.0).timeout
	game_coordinator.item_spawner.spawn_item_at_tile("apple", Vector2i(1, 1))
	
	## Initialize gallery
	#if collection_gallery:
		#var cm = game_coordinator.collection_manager
		#collection_gallery._populate_gallery(cm)
		#collection_gallery._update_progress(cm)

# === UI UPDATE HANDLERS ===

func _on_creature_spawned_for_ui(creature: Creature):
	# Update UI when creature spawns
	if label:
		label.text = creature.creature_name
	#if creature_progress:
		#creature_progress.track_creature(creature)
	
	# Register discovery
	var was_new = game_coordinator.register_discovery(creature)
	if was_new and creature.creature_name != "Lil Egg":
		game_coordinator.creature_spawner.spawn_display_creature(creature)

func _on_evolution_for_ui(old_creature: Creature, new_creature: Creature):
	# Update UI for evolution
	#if creature_progress:
		#creature_progress.cleanup()
		#label.text = ''
	#
	# Track new creature
	_on_creature_spawned_for_ui(new_creature)

func _on_discovery_for_ui(creature_id: String, first_time: bool):
	if first_time:
		print("New discovery: ", creature_id)
		# Could play sound, show notification, etc.

func _on_creature_clicked_for_ui(creature: Creature):
	# Could show click effects, update score, etc.
	pass
	
func _on_boat_reset_requested():
	print("Boat requesting reset!")
	await _animate_creature_to_boat()
	game_coordinator.cleanup_current_creature()
	await game_coordinator.creature_spawner.spawn_egg_from_boat()


func _animate_creature_to_boat():
	var creature = game_coordinator.current_creature
	if not creature or not is_instance_valid(creature):
		return
		
	var tween = get_tree().create_tween()
	tween.tween_property(creature, "global_position", boat.global_position, 0.5)
	tween.parallel().tween_property(creature, "scale", Vector2(0.1, 0.1), 0.5)
	tween.parallel().tween_property(creature, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	if boat:
		boat.play_boarding_animation()
	
func reset_creature_with_boat_animation():
	if game_coordinator.current_creature and is_instance_valid(game_coordinator.current_creature):
		# Move creature to boat
		var tween = get_tree().create_tween()
		
		# Move to boat
		tween.tween_property(game_coordinator.current_creature, "global_position", 
			boat.global_position, 0.5)
		
		# Shrink as if boarding
		tween.parallel().tween_property(game_coordinator.current_creature, "scale", 
			Vector2(0.1, 0.1), 0.5)
		tween.parallel().tween_property(game_coordinator.current_creature, "modulate:a", 
			0.0, 0.3)
		
		await tween.finished
		
		# Tell boat to play boarding animation
		if boat:
			boat.play_boarding_animation()
		
		# Clean up old creature
		game_coordinator._cleanup_current_creature()
	
	# Spawn new egg from boat
	await game_coordinator.creature_spawner.spawn_egg_from_boat()


func connect_creature(creature: Creature):
	creature.main_scene = self
	creature.ready_to_evolve.connect(_on_creature_ready)
	if label:
		label.text = creature.creature_name
	#if creature_progress:
		#creature_progress.track_creature(creature)
	game_coordinator._register_discovery(creature)

func _on_creature_ready(creature: Creature, path):
	print("Main scene: creature ready to evolve!")
	game_coordinator.evolution_manager.trigger_evolution(creature, path)


func is_position_walkable(world_pos: Vector2) -> bool:
	# Convert world position to tile coordinates
	var tile_pos = tile_map_layer.local_to_map(tile_map_layer.to_local(world_pos))

	# Get the tile at this position
	var tile_data = tile_map_layer.get_cell_tile_data(tile_pos)

	# Check if there's a tile and it's not water
	if not tile_data:
		return false

	# You'll need to identify which tiles are water vs land
	# Check your tile source IDs - water tiles might be source 7-14
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	# Assuming sources 0-6 are land, 7+ are water (adjust based on your setup)
	return source_id == 0 

func _on_item_spawned(item: ItemPickup):
	print("Item spawned and registered: ", item.item_data.display_name)
	# Could track active items, limit spawn count, etc.
