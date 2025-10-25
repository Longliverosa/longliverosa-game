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
	
	
	
	dialogue_cluster = generate_dialogue_cluster("MorrisDialogue")
	
	node = generate_dialogue_node("Hey you, nice day for fishing, ain't it? I saw you coming from the Sea. Otters usually prefer to stay out there eating all day. What brings you here?","Pip")
	node.add_choice("Trust the Pepper","TrustPepper") ### A Dialogue
	node.add_choice("Don't trust the Pepper","DontTrustPepper") ### B Dialogue
	dialogue_cluster.add_node(node)
	
	### A Dialogue
	node = generate_dialogue_node("Someone broke into the aquarium to kidnap... otter puppies?! Did you see the person who did it?","Pip","TrustPepper")
	node.add_choice("He was a bald man on a chair!","BaldChair") ### AA Dialogue
	node.add_choice("He looked like a crazy scientist!","CrazyScientist") ### AB Dialogue
	dialogue_cluster.add_node(node)
	### -------------------------------------
	
	### B Dialogue
	node = generate_dialogue_node(" I understand, you don't trust strangers. I forgot to introduce myself. My name is Pip. You look like you could use some help: is there anything i can do?","Pip","DontTrustPepper")
	node.add_choice("A bald man on a chair kidnapped my puppies!","BaldKidnapping") ### BA Dialogue
	node.add_choice("Did you see a crazy scientist on an automatic chair?","ScientistChair") ### BB Dialogue
	dialogue_cluster.add_node(node)
	### -------------------------------------
	
	### AA Dialogue
	node = generate_dialogue_node("I saw a bald man on a chair! He went to the nearby cave. I can show you if you want. Follow me.","Pip","BaldChair")
	dialogue_cluster.add_node(node)
	### -------------------------------------
	### AB Dialogue
	node = generate_dialogue_node("I saw a scientist on a weird automatic chair! He went to the nearby cave. I can show you if you want. Follow me.","Pip","CrazyScientist")
	dialogue_cluster.add_node(node)
	### -------------------------------------
	### BA Dialogue
	node = generate_dialogue_node("I heard of a bald man living in a cave at the end of the beach. I can show you if you want!","Pip","BaldKidnapping")
	dialogue_cluster.add_node(node)
	### -------------------------------------
	### BB Dialogue
	node = generate_dialogue_node("I saw someone with a weird white blanket and a shiny head. He went the cave at the end of the road. I can show you if you want!","Pip","ScientistChair")
	dialogue_cluster.add_node(node)
	### -------------------------------------
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
