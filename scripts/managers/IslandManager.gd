extends Node
class_name IslandManager

# Define island spawn points (you'll set these in the editor)
@export var main_island_center: Vector2 = Vector2(-10, 5)
@export var collection_islands: Array[Vector2] = []

var occupied_islands: Dictionary = {}  # creature_id -> island_index

func get_spawn_position_for_creature(creature_id: String) -> Vector2:
	## Check if this creature type already has an island
	#if creature_id in occupied_islands:
		#var island_idx = occupied_islands[creature_id]
		#return collection_islands[island_idx]
#
	## Assign a new island
	#var available_islands = []
	#for i in collection_islands.size():
		#if not i in occupied_islands.values():
			#available_islands.append(i)
#
	#if available_islands.is_empty():
		## No islands left, spawn on main island
	return main_island_center

	# Assign the first available island
	#var island_idx = available_islands[0]
	#occupied_islands[creature_id] = island_idx
	#return collection_islands[island_idx]
