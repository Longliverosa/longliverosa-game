extends Node
class_name DialogueUiFrontend

signal dialogue_continue(next_id:String)
const TIME_FADEIN_FACTOR:float = 50.0

var button_instances:Array
var node_next_id:String
var tween

func reset() -> void:
	$NinePatchRect/GridContainer.visible = false
	for button_node in button_instances:
		button_node.queue_free()
		$NinePatchRect/GridContainer.remove_child(button_node)
	button_instances.clear()
	tween = create_tween()

func start(character_name:String, text:String, next_id:String = ""):
	reset()
	$NinePatchRect.visible = true
	$NinePatchRect/Name.text = character_name
	
	$NinePatchRect/Text.visible_characters = 0
	$NinePatchRect/Text.text = text
	var text_length = $NinePatchRect/Text.get_total_character_count()
	var dynamic_size_duration = text_length / TIME_FADEIN_FACTOR
	tween.tween_property($NinePatchRect/Text,"visible_characters",text_length,dynamic_size_duration)
	
	node_next_id = next_id

func start_choice(character_name:String, text:String, choices:Array):
	reset()
	$NinePatchRect.visible = true
	
	$NinePatchRect/Name.text = character_name
	
	$NinePatchRect/Text.visible_characters = 0
	$NinePatchRect/Text.text = text
	var text_length = $NinePatchRect/Text.get_total_character_count()
	var dynamic_size_duration = text_length / TIME_FADEIN_FACTOR
	tween.tween_property($NinePatchRect/Text,"visible_characters",text_length,dynamic_size_duration)
	
	$NinePatchRect/GridContainer.visible = false
	tween.tween_property($NinePatchRect/GridContainer, "visible",true, 0)
	
	for choice_dict:Dictionary in choices:
		var button_inst:Button = generate_button(choice_dict["reply"],choice_dict["next_id"])
		button_instances.push_back(button_inst)

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
	if event.is_pressed() && $NinePatchRect/GridContainer.visible == false && $NinePatchRect/Text.visible_ratio == 1:
		on_button_clicked(node_next_id)
	elif event.is_pressed() && $NinePatchRect/GridContainer.visible == false:
		tween.kill()
		$NinePatchRect/Text.visible_ratio = 1
		if $NinePatchRect/GridContainer.get_child_count() > 0:
			$NinePatchRect/GridContainer.visible = true

func clear():
	$NinePatchRect/GridContainer.queue_free()
	$NinePatchRect/Name.queue_free()
	$NinePatchRect/Text.queue_free()
	$NinePatchRect.queue_free()
