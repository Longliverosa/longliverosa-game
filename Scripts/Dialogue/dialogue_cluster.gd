extends Node
class_name DialogueCluster

var dialogue_cluster_name:String
var dialogue_nodes:Array

var ui:DialogueUiFrontend
var game_scene_ref:Node

signal freeze_player
signal unfreeze_player

func _init(cluster_name:String):
	dialogue_cluster_name = cluster_name

### add methods --------------------
func add_node(node:DialogueNode):
	dialogue_nodes.push_back(node)
### --------------------------------

### clear methods ------------------
func clear_nodes():
	for dialogue_node:DialogueNode in dialogue_nodes:
		dialogue_node.queue_free()
	dialogue_nodes.clear()
### --------------------------------

### internal content export --------
func export() ->Dictionary:
	var node_ditcs:Array = []
	
	for dialogue_node:DialogueNode in dialogue_nodes:
		node_ditcs.push_back(dialogue_node.export())
	
	var complete_node_set:Dictionary = {
		"cluster_name":dialogue_cluster_name,
		"nodes": node_ditcs 
		}
	return complete_node_set
### --------------------------------

### internal content import --------
func import(data:Dictionary):
	dialogue_cluster_name = data["Identifier"]
	
	var dialogue_nodes_arr:Array = data["Nodes"]
	
	var dialogue_nodes_label = Node.new()
	dialogue_nodes_label.name = "DialogueNodes"
	self.add_child(dialogue_nodes_label)
	
	for i in dialogue_nodes_arr.size():
		var dialogue_node_dict: Dictionary = dialogue_nodes_arr[i]
		for j in range(dialogue_node_dict["Text"].size()):
			
			var dialogue_node: DialogueNode = DialogueNode.new("import default","import default")
			var override_id = "" 
			if j == 0:
				override_id = dialogue_node_dict["Identifier"]
			if j + 1 == dialogue_node_dict["Text"].size():
				dialogue_node.import(dialogue_cluster_name, dialogue_node_dict["Text"][j], "", dialogue_node_dict["Choices"], override_id)
			else:
				dialogue_node.import(dialogue_cluster_name, dialogue_node_dict["Text"][j], dialogue_node_dict["Text"][j + 1]["Identifier"], [], override_id)
			dialogue_nodes.push_back(dialogue_node)
			
			dialogue_node.name = dialogue_node.node_id
			dialogue_nodes_label.add_child(dialogue_node)
### --------------------------------

### node lookup --------------------
func find_node_by_id(node_id:String) -> DialogueNode:
	var response_node:DialogueNode = DialogueNode.new("Can't find node by id","ERROR")
	for dialogue_node:DialogueNode in dialogue_nodes:
		if dialogue_node.node_id == node_id:
			response_node.queue_free()
			return dialogue_node
	return response_node
### --------------------------------

### dialogue handler ---------------
func initiate_dialogue(game_scene:Node):
	var dialogue_object:DialogueUiFrontend = preload("res://Scenes/UIElements/dialogue.tscn").instantiate()
	if not dialogue_object:
		push_error("Dialogue Object Missing!")
		return
	game_scene.add_child(dialogue_object)
	dialogue_object.dialogue_continue.connect(on_dialogue_continue)
	emit_signal("freeze_player")
	
	if ui == null:
		ui = dialogue_object
	if game_scene_ref == null:
		game_scene_ref = game_scene
	
	var entry_node:DialogueNode = dialogue_nodes[0]
	entry_node.display_node(dialogue_object)

func on_dialogue_continue(next_id:String):
	#print("Cluster recieved call: " + next_id) # Debugging only!
	if next_id == "end":
		reset_ui()
		return
	
	var entry_node:DialogueNode = find_node_by_id(next_id)
	entry_node.display_node(ui)

func reset_ui():
	emit_signal("unfreeze_player")
	game_scene_ref.remove_child(ui)
	
	ui.clear()
	ui.queue_free()
	ui = null
	
	game_scene_ref = null
### --------------------------------
