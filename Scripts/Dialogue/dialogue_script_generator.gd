extends Node


func _input(_event:InputEvent):
	if Input.is_key_pressed(KEY_G):
		generate_example_script()
		print("script generated")

### dialogue script generator ---------
func generate_example_script():
	var dialogue_cluster:DialogueCluster = generate_dialogue_cluster("Intro")
	
	var node:DialogueNode
	
	node = generate_dialogue_node("Hello, traveler! It's me, the voice behind the curtains.","VOID")
	node.add_choice("Hello!","greet_back")
	node.add_choice("I'm scared!","scary_reply")
	dialogue_cluster.add_node(node)
	
	dialogue_cluster.add_node(generate_dialogue_node("Hello back!","PLAYER","greet_back"))
	dialogue_cluster.add_node(generate_dialogue_node("WHO ARE YOU?! I'm scared!","PLAYER","scary_reply"))

	var dialogue_cluster_arr:Array = [dialogue_cluster.export()]

	
	dialogue_cluster = generate_dialogue_cluster("Intro2")
	node = generate_dialogue_node("This is a spooky follow up to the intro","Player")
	dialogue_cluster.add_node(node)
	dialogue_cluster_arr.push_back(dialogue_cluster.export())
	
	var json_string:String = JSON.stringify(dialogue_cluster_arr,"\t",false)
	save_dialogue_file(json_string)

func generate_dialogue_node(text:String,speaker:String,id:String = "start") -> DialogueNode:
	var node = DialogueNode.new(text,speaker,id)
	node.name = "node_"+id
	self.add_child(node)
	return node

func generate_dialogue_cluster(cluster_name:String) -> DialogueCluster:
	var cluster = DialogueCluster.new(cluster_name)
	cluster.name = "cluster_"+cluster_name
	self.add_child(cluster)
	return cluster
### -----------------------------------

### dialogue file handler -------------
func save_dialogue_file(data:String):
	const FILE_NAME: String = "sample_dialogue"
	const FILE_EXTENSION: String = ".json"
	const FULL_PATH: String = "user://" + FILE_NAME + FILE_EXTENSION

	var save_file = FileAccess.open(FULL_PATH,FileAccess.WRITE)
	save_file.store_line(data)
	save_file.close()
### -----------------------------------
