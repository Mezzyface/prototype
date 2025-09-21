# scripts/CreatureFactory.gd
extends Node
class_name CreatureFactory

@export var creature_database: CreatureDatabase
var base_creature_scene = preload("res://scenes/creatures/creature.tscn")

func _ready():
	if not creature_database:
		push_error("CreatureFactory: No database assigned!")
		return
	
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
	
	# Setup visuals
	var sprite = creature.get_node("AnimatedSprite2D")
	if sprite and definition.sprite_resource:
		sprite.sprite_frames = definition.sprite_resource
		sprite.position = definition.sprite_offset
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
	
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
	
	# Setup movement if exists
	if creature.has_node("CreatureMovement"):
		var movement = creature.get_node("CreatureMovement")
		movement.move_speed = definition.base_speed
	
	return creature
