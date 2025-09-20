extends Node
class_name EvolutionManager

@export var evolution_effect_scene: PackedScene

signal evolution_started(creature)
signal evolution_completed(old_creature, new_creature)

func trigger_evolution(creature: Creature):
	if not creature.can_evolve:
		return
		
	if not creature.evolution_scene:
		push_error("No evolution scene set for " + creature.creature_name)
		return
	
	print("Starting evolution for: ", creature.creature_name)
	evolution_started.emit(creature)
	
	# Disable creature during evolution
	creature.can_evolve = false
	creature.set_physics_process(false)
	
	# Start evolution animation
	_perform_evolution(creature)

func _perform_evolution(creature: Creature):
	# Store important data
	var pos = creature.global_position
	var parent = creature.get_parent()
	
	# Visual effect - shrink and glow
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(creature, "scale", Vector2(0.1, 0.1), 0.5)
	tween.parallel().tween_property(creature, "modulate", Color(2, 2, 2), 0.5)
	
	await tween.finished
	
	# Spawn evolved form
	var evolved = creature.evolution_scene.instantiate()
	parent.add_child(evolved)
	evolved.global_position = pos
	
	# Transfer any important data
	if evolved.has_method("inherit_from"):
		evolved.inherit_from(creature)
	
	# Spawn effect and remove old creature
	_spawn_evolution_effect(pos)
	creature.queue_free()
	
	# Animate new creature appearing
	evolved.scale = Vector2(0.1, 0.1)
	var appear_tween = get_tree().create_tween()
	appear_tween.tween_property(evolved, "scale", Vector2(1.0, 1.0), 0.3)
	
	evolution_completed.emit(creature, evolved)
	
func _spawn_evolution_effect(pos: Vector2):
	# Add particles or effect at evolution position
	pass
