extends Node
class_name DialogueNode

enum NodeTypes {REPLYABLE, RESPONSE}

var node_id:String = ""
var node_speaker:String = ""
var node_text:String = ""
var node_choice:Array = []
var node_next_id:String = "end"


func _init(text:String,speaker:String,id:String = "start") -> void:
	node_id = id
	node_text = text
	node_speaker = speaker

### add methods --------------------
func add_choice(reply:String,next_id:String):
	if node_next_id != "end":
		printerr("'%s': Node can't have choices, clear next_id first" % [node_id])
		return
	
	var choice_dict = {
		"reply" : reply,
		"next_id" : next_id
	}
	node_choice.push_back(choice_dict)

func add_next(next_id:String):
	if node_choice.size() > 0:
		printerr("'%s': Node can't directly link next, clear choices first" % [node_id])
		return
	
	node_next_id = next_id
### --------------------------------

### clear methods ------------------
func clear_choices():
	node_choice.clear()

func clear_next():
	node_next_id = "end"

func clear_choice_by_next_id(next_id:String):
	var iterator:int = 0
	var entry_found:bool = false
	
	for choice_entry:Dictionary in node_choice:
		var dict_entry:String = choice_entry["next_id"]
		if dict_entry == next_id:
			entry_found = true
			break
		iterator += 1
	
	if entry_found:
		node_choice.remove_at(iterator)
		clear_choice_by_next_id(next_id)

func clear_choice_by_index(index:int):
	node_choice.remove_at(index)
### --------------------------------

### basic node validation ----------
func validate() -> bool:
	var is_valid:bool = true
	
	if node_text.is_empty():
		printerr("[id:%s] Node has no text present" % [node_id])
		is_valid = false
	if node_speaker.is_empty():
		printerr("[id:%s] Node has no speaker" % [node_id])
		is_valid = false
		
	return is_valid
### --------------------------------

### internal node content export ---
func export() -> String:
	if !validate():
		return ""
	var final_node:Dictionary = {}
	
	if node_choice.size() > 0:
		final_node = {
			"id": node_id,
			"type": NodeTypes.REPLYABLE,
			"speaker": node_speaker,
			"text": node_text,
			"choices": node_choice
		} 
	else:
			final_node = {
			"id": node_id,
			"type": NodeTypes.RESPONSE,
			"speaker": node_speaker,
			"text": node_text,
			"next_id": node_next_id
		} 
	
	var node_content:String = JSON.stringify(final_node,"\t")
	return node_content
### --------------------------------
