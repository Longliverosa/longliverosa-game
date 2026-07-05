extends TextureRect

@export var NEW_GAME_SCENE : PackedScene 
@export var EDITOR_SCENE : PackedScene 

@onready var menu_track : Resource = preload("res://Assets/Sounds/Music/beach_music.mp3")

func _ready() -> void:
	AudioManager.play_music(menu_track)


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(NEW_GAME_SCENE)

func _on_settings_pressed() -> void:
	PauseManager.show_settings_menu()

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_packed(EDITOR_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
