extends Control

var main_menu : PackedScene = preload("res://Scenes/Menu/main_menu.tscn")
@onready var settings_menu : Control = $CanvasLayer/SettingsMenu
@onready var pause_menu : Control = $CanvasLayer/Menu
@onready var background : Control = $CanvasLayer/Background

func _on_continue_button_pressed() -> void:
	PauseManager.set_paused(false)

func _on_settings_button_pressed() -> void:
	pause_menu.hide()
	background.show()
	settings_menu.show()

func _on_main_menu_button_pressed() -> void:
	PauseManager.set_pausable(false)
	PauseManager.set_paused(false)
	AudioManager.play_menu_music()
	get_tree().change_scene_to_packed(main_menu)
