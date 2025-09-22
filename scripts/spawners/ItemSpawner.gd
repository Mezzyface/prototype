extends Node
class_name ItemSpawner

signal item_spawned(item: ItemPickup)

var tile_map: TileMapLayer

# Preload common items
var item_scenes := {
	"apple": preload("res://scenes/Items/apple.tscn"),
	"beer": preload("res://scenes/Items/beer.tscn"),
	"honey": preload("res://scenes/Items/honey.tscn"),
}

# Item metadata for display purposes
var item_info := {
	"apple": {"name": "Fuji Apple", "color": Color(1, 0.3, 0.3)},
	"beer": {"name": "Beer", "color": Color(1, 0.5, 1)},
	"honey": {"name": "Honey", "color": Color(0.5, 1, 0.5)},
}

func setup(_tile_map: TileMapLayer):
	tile_map = _tile_map

func get_item_display_name(item_key: String) -> String:
	return item_info.get(item_key, {}).get("name", item_key)

func get_item_color(item_key: String) -> Color:
	return item_info.get(item_key, {}).get("color", Color.WHITE)

func spawn_item_at_tile(item_name: String, tile_pos: Vector2i) -> ItemPickup:
	if not item_name in item_scenes:
		push_error("Item not found: " + item_name)
		return null
	
	var item = item_scenes[item_name].instantiate()
	get_tree().current_scene.add_child(item)
	item.add_to_group("items")
	
	# Convert tile to world position
	var world_pos = tile_map.map_to_local(tile_pos)
	item.global_position = world_pos
	
	item_spawned.emit(item)
	print("Spawned %s at tile %s (world: %s)" % [item_name, tile_pos, world_pos])
	
	return item

func spawn_item_at_position(item_name: String, world_pos: Vector2) -> ItemPickup:
	if not item_name in item_scenes:
		push_error("Item not found: " + item_name)
		return null
	
	var item = item_scenes[item_name].instantiate()
	get_tree().current_scene.add_child(item)
	item.add_to_group("items")
	item.global_position = world_pos
	
	item_spawned.emit(item)
	print("Spawned %s at position %s" % [item_name, world_pos])
	
	return item

func spawn_random_item_at_random_tile(tile_range: Rect2i) -> ItemPickup:
	# Pick a random item
	var item_names = item_scenes.keys()
	var random_item = item_names[randi() % item_names.size()]
	
	# Pick a random tile within range
	var random_tile = Vector2i(
		randi_range(tile_range.position.x, tile_range.end.x),
		randi_range(tile_range.position.y, tile_range.end.y)
	)
	
	return spawn_item_at_tile(random_item, random_tile)

# Spawn items periodically
func start_random_spawning(interval: float = 5.0, tile_range: Rect2i = Rect2i(-3, -3, 6, 6)):
	while true:
		await get_tree().create_timer(interval).timeout
		spawn_random_item_at_random_tile(tile_range)
