#extends Node2D
extends Area2D
class_name DialogueManager

# each containing node is an orphan, implement better solution @ later point
var dialogue_cluster_collection:Array

func _on_body_entered(_body):
	# Implement start_dialogue function with following functionality
	if dialogue_cluster_collection.is_empty():
		return
	dialogue_cluster_collection[0].connect("freeze_player",func(): freeze_player())
	dialogue_cluster_collection[0].connect("unfreeze_player",func(): unfreeze_player())
	dialogue_cluster_collection[0].initiate_dialogue(get_parent())

func _ready():
	generate_example_script()
	var dialogue_data:String = load_dialogue_file()
	if dialogue_data == "":
		return
	parse_dialogue_data(dialogue_data)

func generate_example_script():
	var dialogue_cluster:DialogueCluster = DialogueCluster.new("Intro")
	var node:DialogueNode

	node = DialogueNode.new("Hello, traveler! It's me, the voice behind the curtains.","VOID")
	node.add_choice("Hello!","greet_back")
	node.add_choice("I'm scared!","scary_reply")
	dialogue_cluster.add_node(node)
	
	dialogue_cluster.add_node(DialogueNode.new("Hello back!","PLAYER","greet_back"))
	dialogue_cluster.add_node(DialogueNode.new("WHO ARE YOU?! I'm scared!","PLAYER","scary_reply"))

	var dialogue_cluster_arr:Array = [dialogue_cluster.export()]
	var json_string:String = JSON.stringify(dialogue_cluster_arr,"\t",false)
	save_dialogue_file(json_string)
	
	for dialogue_node:DialogueNode in dialogue_cluster.dialogue_nodes:
		dialogue_node.queue_free()
	
	dialogue_cluster.queue_free()
	node.queue_free()

func parse_dialogue_data(data:String):
	var json = JSON.new()
	var error = json.parse(data)
	
	if error == OK:
		var data_recieved:Array = json.data
		for n in data_recieved.size():
			var dialogue_cluster_dict:Dictionary = data_recieved[n]
			var dialogue_cluster = DialogueCluster.new(dialogue_cluster_dict["cluster_name"])
			dialogue_cluster.import(dialogue_cluster_dict)
			dialogue_cluster_collection.push_back(dialogue_cluster)
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
	
	# Debugging purposes only
	#var temp_arr:Array = [dialogue_cluster_collection[0].export()]
	#var json_string:String = JSON.stringify(temp_arr,"\t",false)
	#print(json_string)

func save_dialogue_file(data:String):
	const FILE_NAME: String = "sample_dialogue"
	const FILE_EXTENSION: String = ".json"
	const FULL_PATH: String = "user://" + FILE_NAME + FILE_EXTENSION

	var save_file = FileAccess.open(FULL_PATH,FileAccess.WRITE)
	save_file.store_line(data)
	save_file.close()

func load_dialogue_file() -> String:
	const FILE_NAME: String = "sample_dialogue"
	const FILE_EXTENSION: String = ".json"
	const FULL_PATH: String = "user://" + FILE_NAME + FILE_EXTENSION
	
	if not FileAccess.file_exists(FULL_PATH):
		printerr("couldn't find dialogue file")
		return ""
	var save_file = FileAccess.open(FULL_PATH,FileAccess.READ)
	var save_file_content:String = save_file.get_as_text()
	
	return save_file_content

func _exit_tree() -> void:
	# clears all the orphaned nodes accumulated to avoid memory leaks
	for dialogue_cluster:DialogueCluster in dialogue_cluster_collection:
		for dialogue_node:DialogueNode in dialogue_cluster.dialogue_nodes:
			dialogue_node.queue_free()
		dialogue_cluster.queue_free()

func freeze_player():
	var player_obj:CharacterBody2D = self.get_parent().get_node("Player")
	if player_obj:
		player_obj.dialogue_active = true

func unfreeze_player():
	var player_obj:CharacterBody2D = self.get_parent().get_node("Player")
	if player_obj:
		player_obj.dialogue_active = false
