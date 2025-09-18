#extends Node2D
extends Area2D
class_name DialogueManager

#func load_dialogue_data():

#func _on_body_entered(body):
	#generate_example_script()

func _ready():
	generate_example_script()

func generate_example_script():
	var node:DialogueNode = DialogueNode.new("Hello, traveler! It's me, the voice behind the curtains.","VOID")
	node.add_choice("Hello!","greet_back")
	node.add_choice("I'm scared!","scary_reply")
	
	#node.export()
	node.validate()
	
	var response_node:DialogueNode = DialogueNode.new("Hello back!","PLAYER","greet_back")
	print(response_node.export())
	
	## output example for later data processing
	var my_dict = {
		"dialogue_name": "Intro",
		"nodes":[
			{
				"id": "start", # standartized "start"
				"type": "replyable", # change to enum of sorts
				"speaker": "VOID", # change to character enum of sorts
				"text": "Hello, traveler! It's me, the voice behind the curtains.",
				"choices":[
					{"reply": "Hello!", "next":"greet_back"},
					{"reply": "I'm scared!", "next":"scary_reply"}
				]
			},
			{
				"id": "greet_back",
				"type": "response", # change to enum of sorts
				"speaker": "PLAYER",
				"text": "Hello back!",
				"next_id": "end"
			},
			{
				"id": "scary_reply",
				"type": "response", # change to enum of sorts
				"speaker": "PLAYER",
				"text": "WHO ARE YOU?! I'm scared!",
				"next_id": "end"
			}
		]
	}
	var json_string = JSON.stringify(my_dict, "\t")
	#print(json_string)
	save_game(json_string)


func save_game(data):
	const FILE_NAME: String = "sample_dialogue"
	const FILE_EXTENSION: String = ".json"
	const FULL_PATH: String = "user://" + FILE_NAME + FILE_EXTENSION
	
	var save_file = FileAccess.open(FULL_PATH,FileAccess.WRITE)
	save_file.store_line(data)
