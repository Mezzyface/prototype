extends Node2D

@onready var collectionManager = CollectionManager.new()
@onready var evolution_manager = EvolutionManager.new()
@onready var island_manager = IslandManager.new()
@onready var creature_progress: CreatureProgress = %CreatureProgress
#@onready var evolution_container: HBoxContainer = %EvolutionPreview
@onready var collection_gallery: CollectionGallery = $CanvasLayer/CollectionGallery
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready():
	add_child(evolution_manager)
	add_child(collectionManager)
	
	spawn_egg_at_tile(0, 0)
	
	# Connect to evolution completed signal
	evolution_manager.evolution_completed.connect(_on_evolution_completed)
	
	if collection_gallery:
		# Build gallery
		collection_gallery._populate_gallery(collectionManager)
		collection_gallery._update_progress(collectionManager)
	
func connect_creature(creature: Creature):
	creature.main_scene = self
	creature.ready_to_evolve.connect(_on_creature_ready)
	creature_progress.track_creature(creature)
	_register_discovery(creature)

func _on_creature_ready(creature: Creature, path):
	print("Main scene: creature ready to evolve!")
	evolution_manager.trigger_evolution(creature, path)

func _on_evolution_completed(old_creature: Creature, new_creature: Creature):
	print("Evolution complete, updating tracking to new creature")

	# Clean up old creature tracking in progress bar
	if creature_progress:
		creature_progress.cleanup()  # You'll need to implement this

	# Connect and track the new creature
	connect_creature(new_creature)

func _register_discovery(creature: Creature):
	#if collection_gallery:
		## Build gallery
		#collection_gallery._populate_gallery(collectionManager)
		#collection_gallery._update_progress(collectionManager)
	# Use creature name as ID for now
	var was_new = collectionManager.register_creature(creature.evolutionData.creature_id)
	if was_new:
		spawn_discovered_creature(creature)
		print("First time discovering: ", creature.evolutionData.creature_id)

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

func spawn_discovered_creature(creature: Creature):
	var scene_path = creature.scene_file_path

	if scene_path.is_empty():
		print("ERROR: No scene path for creature: ", creature.creature_name)
		# Fallback to manual mapping
		#scene_path = _get_scene_path_for_id(creature.evolutionData.creature_id)
	
	if scene_path.is_empty():
		return
		
	print("Loading scene: ", scene_path)
	
	# Create fresh instance
	var display_copy = load(scene_path).instantiate()
	
	# Position on collection island
	var tile_pos = Vector2i(-10, 5)
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	display_copy.global_position = world_pos
	
	add_child(display_copy)
	
	# Wait for initialization
	await get_tree().process_frame
	
	# Configure as display creature with movement constraint
	display_copy.configure_as_display(world_pos, 120.0)
	
	print("Spawned display creature at ", world_pos)

func spawn_egg_at_tile(tile_x: int, tile_y: int):
	var egg_scene = preload("res://scenes/creatures/lil_egg.tscn")
	var egg = egg_scene.instantiate()

	# Convert tile to world position
	var tile_pos = Vector2i(tile_x, tile_y)
	var world_pos = tile_map_layer.map_to_local(tile_pos)

	add_child(egg)
	egg.global_position = world_pos

	# Make sure it's properly set up
	egg.can_evolve = true

	# Connect it!
	connect_creature(egg)

	print("Spawned egg at tile ", tile_pos, " (world: ", world_pos, ")")
