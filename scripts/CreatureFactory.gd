# In scripts/CreatureFactory.gd

extends Node
class_name CreatureFactory

@export var creature_database: CreatureDatabase
var base_creature_scene = preload("res://scenes/creatures/creature.tscn")

const STAGE_TARGET_HEIGHTS = {
	Enums.CreatureStage.EGG: 32,     # Eggs are 32 pixels tall
	Enums.CreatureStage.BABY: 32,    # Babies are 32 pixels tall
	Enums.CreatureStage.KID: 48,     # Kids are 48 pixels tall
	Enums.CreatureStage.TEEN: 64,    # Teens are 64 pixels tall
	Enums.CreatureStage.ADULT: 96    # Adults are 96 pixels tall
}

func _ready():
	if not creature_database:
		push_error("CreatureFactory: No database assigned!")
		return
	
	print("CreatureFactory: Database has %d creatures" % creature_database.creatures.size())
	
	if not creature_database.validate_all():
		push_error("CreatureFactory: Database validation failed!")

func create_creature(creature_id: String) -> Creature:
	if not creature_database:
		push_error("No creature database!")
		return null
		
	var definition = creature_database.get_creature(creature_id)
	if not definition:
		push_error("No definition for creature: " + creature_id)
		return null
	
	# Instance base creature
	var creature = base_creature_scene.instantiate() as Creature
	
	# Apply definition data
	creature.creature_id = creature_id
	creature.creature_name = definition.display_name
	creature.definition = definition
	
	# Add debug output to verify evolutions are being set
	print("Created %s with %d possible evolutions" % [
		definition.display_name, 
		definition.evolutions.size()
	])

	creature.creature_stage = definition.stage
	creature.base_speed = definition.base_speed
	creature.can_seek_items = definition.can_seek_items
	creature.can_evolve = true  # Most creatures can evolve
	
	# Setup visuals
	var sprite = creature.get_node("AnimatedSprite2D")
	if sprite and definition.sprite_resource:
		sprite.sprite_frames = definition.sprite_resource
		sprite.position = definition.sprite_offset
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
			
		var scale_factor = _calculate_scale_for_stage(sprite, definition.stage)
		creature.scale = Vector2(scale_factor, scale_factor)
		
		print("Scaled %s: Original sprite height = %d, Target = %d, Scale = %.2f" % [
			definition.display_name,
			_get_sprite_height(sprite),
			STAGE_TARGET_HEIGHTS.get(definition.stage, 32),
			scale_factor
		])
	
	# Setup collision
	var collision = creature.get_node("CollisionShape2D")
	var area_collision = creature.get_node("Area2D/CollisionShape2D")
	
	if collision:
		var circle = CircleShape2D.new()
		circle.radius = definition.collision_radius
		collision.shape = circle
		collision.position = definition.sprite_offset + Vector2(0, 7)
	
	if area_collision:
		var circle = CircleShape2D.new()
		circle.radius = definition.collision_radius
		area_collision.shape = circle
		area_collision.position = definition.sprite_offset + Vector2(0, 7)
	
	print("Successfully created creature: ", creature.creature_name)
	return creature
	
# NEW: Helper function to get the actual sprite height
func _get_sprite_height(sprite: AnimatedSprite2D) -> int:
	if not sprite.sprite_frames:
		return 32  # Default fallback
		
	# Get the first frame of the idle animation to measure
	var idle_frames = sprite.sprite_frames.get_frame_count("idle")
	if idle_frames > 0:
		var texture = sprite.sprite_frames.get_frame_texture("idle", 0)
		if texture:
			return texture.get_height()
	
	# Fallback - try any animation
	var animations = sprite.sprite_frames.get_animation_names()
	for anim_name in animations:
		var frame_count = sprite.sprite_frames.get_frame_count(anim_name)
		if frame_count > 0:
			var texture = sprite.sprite_frames.get_frame_texture(anim_name, 0)
			if texture:
				return texture.get_height()
	
	return 32  # Final fallback

# NEW: Calculate the scale needed to reach target height
func _calculate_scale_for_stage(sprite: AnimatedSprite2D, stage: Enums.CreatureStage) -> float:
	var current_height = _get_sprite_height(sprite)
	var target_height = STAGE_TARGET_HEIGHTS.get(stage, 32)
	
	# Calculate scale needed to reach target height
	return float(target_height) / float(current_height)
