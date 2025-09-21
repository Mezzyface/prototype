# tools/ValidateDatabase.gd
@tool
extends EditorScript

func _run():
	var db = load("res://resources/creature_database.tres") as CreatureDatabase
	
	print("=== Validating Creature Database ===")
	print("Total creatures: ", db.creatures.size())
	
	for creature_def in db.creatures:
		print("\nCreature: ", creature_def.display_name)
		print("  ID: ", creature_def.creature_id)
		print("  Stage: ", Enums.CreatureStage.keys()[creature_def.stage])
		print("  Evolutions: ", creature_def.evolutions.size())
		
		for evo in creature_def.evolutions:
			print("    -> ", evo.target_creature_id, ": ", evo.requirements.size() )
	
	#if db.validate_all():
		#print("\n✅ All creatures valid!")
	#else:
		#print("\n❌ Validation failed!")
