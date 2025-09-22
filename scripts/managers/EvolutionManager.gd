extends Node
class_name EvolutionManager

@export var evolution_effect_scene: PackedScene

signal evolution_started(creature)
signal evolution_completed(old_creature, new_creature)

var creature_factory: CreatureFactory

func setup(_factory: CreatureFactory):
	creature_factory = _factory
	
func trigger_evolution(creature: Creature, evolution_req: EvolutionRequirement):
	if not creature.can_evolve:
		return

	print("Starting evolution for: ", creature.creature_name)
	evolution_started.emit(creature)
	
	# Disable creature during evolution
	creature.can_evolve = false
	creature.set_physics_process(false)
	
	# Start evolution animation
	_perform_evolution(creature, evolution_req)

func _perform_evolution(creature: Creature, evolution_req: EvolutionRequirement):
	# Store important data
	var pos = creature.global_position
	var parent = creature.get_parent()

	var target_id = evolution_req.target_creature_id

	# Play the sprite Evolution Animation
	if creature.sprite and creature.sprite.sprite_frames.has_animation("evolve"):
		print("Playing evolve animation")
		creature.sprite.play("evolve")

		# Wait for animation to finish before continuing
		await creature.sprite.animation_finished
	else:
		_spawn_evolution_effect(pos)

	# Visual effect - shrink and glow
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(creature, "scale", Vector2(0.1, 0.1), 0.5)
	tween.parallel().tween_property(creature, "modulate", Color(2, 2, 2), 0.5)
	
	await tween.finished
	
	var evolved = creature_factory.create_creature(evolution_req.target_creature_id)
	if not evolved:
		push_error("Failed to create evolved creature: " + evolution_req.target_creature_id)
		return
	
	parent.add_child(evolved)
	evolved.global_position = pos
	
	print("Tracking creature: ", evolved.creature_name)  # This will show if name is empty
	
	# Transfer any important data
	if evolved.has_method("inherit_from"):
		evolved.inherit_from(creature)
	
	var evolved_final_scale = Vector2(evolved.target_scale, evolved.target_scale)

	creature.queue_free()
	
	# Animate new creature appearing
	evolved.scale = Vector2(0.1, 0.1)
	var appear_tween = get_tree().create_tween()
	appear_tween.tween_property(evolved, "scale", evolved_final_scale, 0.3)
	print("Emit the Signal")  
	
	evolution_completed.emit(creature, evolved)
	
func _spawn_evolution_effect(pos: Vector2):
	# Load your AnimatedSprite2D scene
	var effect_scene = preload("res://scenes/evolve_effect.tscn")
	var effect_instance = effect_scene.instantiate()

	# Add it to the current scene
	get_tree().current_scene.add_child(effect_instance)

	# Set the position
	effect_instance.global_position = pos

	# Play the animation (replace "default" with your animation name)
	effect_instance.play("evolve")

	# Connect to the animation_finished signal to remove it when done
	effect_instance.animation_finished.connect(func():
		effect_instance.queue_free()
	)
