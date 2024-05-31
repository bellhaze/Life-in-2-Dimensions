extends Node3D

var greet_counter = 0
var npc_total = 0

func _ready():
	npc_total = get_tree().get_nodes_in_group("NPCs").size()
	for i in npc_total:
		var npc = get_tree().get_nodes_in_group("NPCs")[i]
		npc.npc_greeted.connect(_on_npc_greeted)

func _on_npc_greeted():
	greet_counter += 1
	print("Greeted ", greet_counter, "/", npc_total, " NPCs")
	if greet_counter == npc_total:
		win()
		
func win():
	print("Greeted all NPCs!")
	$Victory.play()
