extends Node2D
class_name DialogueManager

var dialogue_cluster_collection:Array

func _ready():
	var dialogue_data:String = load_dialogue_file()
	if dialogue_data == "":
		return
	parse_dialogue_data(dialogue_data)
	connect_trigger()

# ANNOUNCEMENT: Dialogue file has to be generated for the Dialogue System to work!!!
# To generate Dialogue, enter level, press "G" and reload the game.
# Godot should output an info after the script has been generated

### dialogue file handler -------------
func parse_dialogue_data(data:String):
	var json = JSON.new()
	var error = json.parse(data)
	
	if error == OK:
		var data_recieved:Array = json.data
		
		var dialogue_clusters:Node = Node.new()
		dialogue_clusters.name = "DialogueClusters"
		self.add_child(dialogue_clusters)
		
		for n in data_recieved.size():
			var dialogue_cluster_dict:Dictionary = data_recieved[n]
			var dialogue_cluster = DialogueCluster.new(dialogue_cluster_dict["cluster_name"])
			dialogue_cluster.import(dialogue_cluster_dict)
			dialogue_cluster_collection.push_back(dialogue_cluster)
			
			dialogue_cluster.name = dialogue_cluster.dialogue_cluster_name
			dialogue_clusters.add_child(dialogue_cluster)
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())

func save_dialogue_file(data:String):
	### Technically redudant, used method is in dialogue_script_generator.gd
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
### -----------------------------------

### player interaction ----------------
func freeze_player():
	var player_obj:CharacterBody2D = self.get_parent().get_node("Player")
	if player_obj:
		player_obj.dialogue_active = true

func unfreeze_player():
	var player_obj:CharacterBody2D = self.get_parent().get_node("Player")
	if player_obj:
		player_obj.dialogue_active = false
### -----------------------------------

### connection methods ----------------
func connect_clusters():
	if dialogue_cluster_collection.is_empty():
		return
	for dialogue_cluster:DialogueCluster in dialogue_cluster_collection:
		dialogue_cluster.connect("freeze_player",func(): freeze_player())
		dialogue_cluster.connect("unfreeze_player",func(): unfreeze_player())

func connect_trigger():
	for trigger in get_tree().get_nodes_in_group("dialogue_trigger"):
		trigger.connect("dialogue_triggered",Callable(self,"start_dialogue"))
### -----------------------------------

### dialogue methods ------------------
func start_dialogue(cluster_name:String):
	if dialogue_cluster_collection.is_empty():
		return
	connect_clusters()
	for dialogue_cluster:DialogueCluster in dialogue_cluster_collection:
		if dialogue_cluster.dialogue_cluster_name == cluster_name:
			dialogue_cluster.initiate_dialogue(get_parent())
			return
### -----------------------------------

### garbage collector -----------------
func _exit_tree() -> void:
	# clears all the orphaned nodes accumulated to avoid memory leaks
	for dialogue_cluster:DialogueCluster in dialogue_cluster_collection:
		for dialogue_node:DialogueNode in dialogue_cluster.dialogue_nodes:
			dialogue_node.queue_free()
		dialogue_cluster.queue_free()
### -----------------------------------
