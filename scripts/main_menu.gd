extends Control


func _on_creature_collector_pressed():
	get_tree().change_scene_to_file("res://scenes/critter_collector.tscn")

func _on_idle_game_pressed():
	print("Pushing Idle Game")
