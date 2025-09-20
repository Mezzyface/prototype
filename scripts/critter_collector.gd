extends Node2D

@onready var collectionManager = CollectionManager.new()
@onready var evolution_manager = EvolutionManager.new()
@onready var creature_progress: CreatureProgress = %CreatureProgress
#@onready var evolution_container: HBoxContainer = %EvolutionPreview
@onready var starter_creature: Creature = $Creature
@onready var collection_gallery: CollectionGallery = $CanvasLayer/CollectionGallery


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
	creature.ready_to_evolve.connect(_on_creature_ready)
	creature_progress.track_creature(creature)
	_register_discovery(creature)

func _on_creature_ready(creature: Creature, path):
	print("Main scene: creature ready to evolve!")
	evolution_manager.trigger_evolution(creature, path)


#func display_evolution_previews(evolutions: Array):
	## Clear existing previews
	#for child in evolution_container.get_children():
		#child.queue_free()
#
	## Add each evolution as a black silhouette
	#for evolution_scene in evolutions:
		#var texture = get_evolution_preview(evolution_scene)
		#if texture:
			#add_evolution_to_ui(texture)
	
#func add_evolution_to_ui(texture: Texture2D):
	## Create TextureRect for the evolution
	#var texture_rect = TextureRect.new()
	#texture_rect.texture = texture
#
	## Make it black silhouette
	#texture_rect.modulate = Color.BLACK
#
	## Optional: Set consistent size
	#texture_rect.custom_minimum_size = Vector2(64, 64)  # Adjust size as needed
	#texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	#texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	## Add to container
	#evolution_container.add_child(texture_rect)	

#func get_evolution_preview(evolution_scene: PackedScene) -> Texture2D:
	#if not evolution_scene:
		#return null
		#
	## Load the scene and get its sprite
	#var preview = evolution_scene.instantiate()
	#var preview_sprite = preview.get_node("AnimatedSprite2D")
	#var texture = preview_sprite.sprite_frames.get_frame_texture("idle", 0)
	#preview.queue_free()
	#
	#return texture

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
		print("First time discovering: ", creature.evolutionData.creature_id)
