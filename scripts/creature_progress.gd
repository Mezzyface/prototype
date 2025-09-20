extends Control
class_name CreatureProgress

@onready var name_label = $Label
@onready var progress_bar = $ProgressBar

var tracked_creature: Creature
var neededToEvolve: float

func track_creature(creature: Creature):
	# Disconnect from old creature if exists
	cleanup()
	
	tracked_creature = creature
	
	if not creature:
		return
	
	if creature.creature_name == "":
		print("Tracking creature: ", creature.creature_name)  # This will show if name is empty
		print("Has evolution data: ", creature.evolutionData != null)

	
	# Connect to creature signals
	creature.clicked.connect(_on_creature_clicked)
	
	# Update UI with new creature info
	update_display(creature)
	
	# Update bar
	_update_progress()
	
func _on_creature_clicked(_creature):
	_update_progress()
	
func update_display(creature: Creature):
	name_label.text = creature.creature_name
# Check if evolutionData exists AND has evolutions
	if creature.evolutionData and creature.evolutionData.possible_evolutions:
		neededToEvolve = creature.evolutionData.possible_evolutions[0].requirement_value
	else:
		progress_bar.visible = false
	

func _update_progress():
	if not tracked_creature:
		return
		
	var progress = float(tracked_creature.clicks_received) / float(neededToEvolve)
	progress_bar.value = progress * 100
	
	# Color based on progress
	if progress >= 1.0:
		progress_bar.modulate = Color.GREEN
	elif progress >= 0.7:
		progress_bar.modulate = Color.YELLOW
	else:
		progress_bar.modulate = Color.WHITE

func cleanup():
	if tracked_creature and tracked_creature.clicked.is_connected(_on_creature_clicked):
		tracked_creature.clicked.disconnect(_on_creature_clicked)
	tracked_creature = null
