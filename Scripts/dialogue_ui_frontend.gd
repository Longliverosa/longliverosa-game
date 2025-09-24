extends Node
class_name DialogueUiFrontend

signal dialogue_continue(next_id:String)

var button_instances:Array
var node_next_id:String


func reset() -> void:
	$NinePatchRect/GridContainer.visible = false
	for button_node in button_instances:
		button_node.queue_free()
		$NinePatchRect/GridContainer.remove_child(button_node)
	button_instances.clear()

func start(character_name:String, text:String, next_id:String = ""):
	reset()
	$NinePatchRect.visible = true
	$NinePatchRect/Name.text = character_name
	$NinePatchRect/Text.text = text
	node_next_id = next_id

func start_choice(character_name:String, text:String, choices:Array):
	reset()
	$NinePatchRect/GridContainer.visible = true
	$NinePatchRect.visible = true
	
	for choice_dict:Dictionary in choices:
		var button_inst:Button = generate_button(choice_dict["reply"],choice_dict["next_id"])
		button_instances.push_back(button_inst)
	
	$NinePatchRect/Name.text = character_name
	$NinePatchRect/Text.text = text

func generate_button(text:String,next_id:String) -> Button:
	var button_instance = Button.new()
	# Content Filling
	button_instance.text = text
	# Theming
	button_instance.flat = true
	button_instance.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button_instance.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button_instance.add_theme_color_override("font_color",Color("000000"))
	button_instance.add_theme_color_override("font_focus_color",Color("000000"))
	button_instance.add_theme_color_override("font_pressed_color",Color("621300"))
	button_instance.add_theme_color_override("font_hover_pressed_color",Color("621300"))
	button_instance.add_theme_color_override("font_hover_color",Color("621300"))
	
	$NinePatchRect/GridContainer.add_child(button_instance)
	
	# Signal linking internaly
	button_instance.pressed.connect(func(): on_button_clicked(next_id))
	return button_instance

func on_button_clicked(next_id:String):
	# Singal exposure externaly
	emit_signal("dialogue_continue",next_id)

func _input(event:InputEvent):
	if event.is_pressed() && $NinePatchRect/GridContainer.visible == false:
		on_button_clicked(node_next_id)

func clear():
	$NinePatchRect/GridContainer.queue_free()
	$NinePatchRect/Name.queue_free()
	$NinePatchRect/Text.queue_free()
	$NinePatchRect.queue_free()
