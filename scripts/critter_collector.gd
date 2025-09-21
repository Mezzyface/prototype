extends Node2D

@onready var collectionManager = CollectionManager.new()
@onready var evolution_manager = EvolutionManager.new()
@onready var island_manager = IslandManager.new()
@onready var creature_progress: CreatureProgress = %CreatureProgress
#@onready var evolution_container: HBoxContainer = %EvolutionPreview
@onready var starter_creature: Creature = $Creature
@onready var collection_gallery: CollectionGallery = $CanvasLayer/CollectionGallery
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready():
	add_child(evolution_manager)
	add_child(collectionManager)
	if starter_creature:
		connect_creature(starter_creature)
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
	if collection_gallery:
		# Build gallery
		collection_gallery._populate_gallery(collectionManager)
		collection_gallery._update_progress(collectionManager)
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
	return source_id >= 0 and source_id <= 6

func spawn_discovered_creature(creature: Creature):
	
	var tile_pos = Vector2i(-10, 5)
	var world_pos = tile_map_layer.map_to_local(tile_pos)
	var display_copy  = create_display_copy(creature)
	add_child(display_copy)
	creature.global_position = world_pos
	
	# Make it just wander, no evolution
	creature.can_evolve = false
	connect_creature(creature)

func create_display_copy(original: Creature) -> Creature:
	# Use duplicate with flags to deep copy
	var copy = original.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)

	# Manually duplicate the visual components
	var original_sprite = original.get_node("AnimatedSprite2D")
	var copy_sprite = copy.get_node("AnimatedSprite2D")

	# Copy the sprite frames and animation
	copy_sprite.sprite_frames = original_sprite.sprite_frames
	copy_sprite.animation = original_sprite.animation
	copy_sprite.frame = 0
	copy_sprite.play("idle")

	# Reset creature state for display version
	copy.can_evolve = false
	copy.clicks_received = 0
	copy.time_alive = 0.0

	# Disconnect any signals we don't want
	#if copy.ready_to_evolve.is_connected(_on_creature_ready):
		#copy.ready_to_evolve.disconnect(_on_creature_ready)

	return copy
