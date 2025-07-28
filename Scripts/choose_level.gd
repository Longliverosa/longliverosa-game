extends Control

var levels : Array[LevelBase] = []
var current_level : LevelBase 
var current_level_index : int = 0

@onready var previous_button = %PreviousLevel
@onready var next_button = %NextLevel
@onready var level_locked = %LevelLocked
@onready var level_name : RichTextLabel = %LevelName
@onready var level_icon : TextureRect = %LevelIcon


func _ready() -> void:
	levels = LevelLoader.all_levels.duplicate()
	for level in levels.filter(func(level): return level.depends_on != -1):
		var depend_on_index = levels.find_custom(func(other): return other.order == level.depends_on)
		if depend_on_index != -1 and !levels[depend_on_index].completed:
			level.locked = true
	current_level = levels[current_level_index]
	previous_button.visible = current_level_index != 0
	set_information_for_current_level()

	
func set_information_for_current_level():
	level_locked.visible = current_level.locked
	level_name.text = current_level.name
	level_icon.texture = current_level.icon
	
func _on_play_current_level_pressed() -> void:
	get_tree().change_scene_to_packed(current_level.scene)

func _on_previous_level_pressed() -> void:
	current_level_index = current_level_index - 1
	current_level = levels[current_level_index]
	previous_button.visible = current_level_index != 0
	next_button.visible = current_level_index != levels.size() - 1 
	set_information_for_current_level()
	

func _on_next_level_pressed() -> void:
	current_level_index = current_level_index + 1
	current_level = levels[current_level_index]
	previous_button.visible = current_level_index != 0
	next_button.visible = current_level_index != levels.size() - 1 
	set_information_for_current_level()
