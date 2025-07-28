extends TextureRect

@export var NEW_GAME_SCENE : PackedScene 
@export var SETTINGS_SCENE : PackedScene 


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(NEW_GAME_SCENE)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(SETTINGS_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
