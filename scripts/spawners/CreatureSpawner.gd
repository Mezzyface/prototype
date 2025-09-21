extends Node
class_name CreatureSpawner

signal creature_spawned(creature: Creature)

var tile_map: TileMapLayer
var boat: Boat

func setup(_tile_map: TileMapLayer, _boat: Boat):
	tile_map = _tile_map
	boat = _boat

func spawn_egg_at_tile(tile_x: int, tile_y: int, can_evolve: bool = true) -> Creature:
	var egg_scene = preload("res://scenes/creatures/lil_egg.tscn")
	var egg = egg_scene.instantiate()
	
	# Convert tile to world position
	var tile_pos = Vector2i(tile_x, tile_y)
	var world_pos = tile_map.map_to_local(tile_pos)
	
	get_tree().current_scene.add_child(egg)
	egg.global_position = world_pos
	egg.can_evolve = can_evolve
	
	creature_spawned.emit(egg)
	print("Spawned egg at tile ", tile_pos, " (world: ", world_pos, ")")
	
	return egg

func spawn_egg_from_boat(can_evolve: bool = true) -> Creature:
	var egg_scene = preload("res://scenes/creatures/lil_egg.tscn")
	var egg = egg_scene.instantiate()
	
	# Start at boat position
	get_tree().current_scene.add_child(egg)
	egg.global_position = boat.global_position
	egg.can_evolve = can_evolve
	
	# Start small
	egg.scale = Vector2(0.1, 0.1)
	egg.modulate.a = 0.0
	
	# Animate egg moving from boat to spawn point
	var tile_pos = Vector2i(0, 0)
	var spawn_pos = tile_map.map_to_local(tile_pos)
	
	var tween = get_tree().create_tween()
	
	# Move to position
	tween.parallel().tween_property(egg, "global_position", 
		spawn_pos, 1.0).set_trans(Tween.TRANS_QUAD)
	
	# Grow and fade in
	tween.parallel().tween_property(egg, "scale", 
		Vector2(1.0, 1.0), 0.8)
	tween.parallel().tween_property(egg, "modulate:a", 
		1.0, 0.5)
	
	# Bounce landing
	tween.tween_property(egg, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(egg, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	
	creature_spawned.emit(egg)
	print("New egg spawned from boat!")
	
	return egg

func spawn_display_creature(original_creature: Creature) -> Creature:
	var scene_path = original_creature.scene_file_path
	
	if scene_path.is_empty():
		print("ERROR: No scene path for creature: ", original_creature.creature_name)
		return null
		
	print("Loading scene: ", scene_path)
	
	# Create fresh instance
	var display_copy = load(scene_path).instantiate()
	
	# Position on collection island
	var tile_pos = Vector2i(-10, 5)
	var world_pos = tile_map.map_to_local(tile_pos)
	display_copy.global_position = world_pos
	
	get_tree().current_scene.add_child(display_copy)
	
	# Wait for initialization
	await get_tree().process_frame
	
	# Configure as display creature with movement constraint
	display_copy.configure_as_display(world_pos, 120.0)
	
	print("Spawned display creature at ", world_pos)
	return display_copy
