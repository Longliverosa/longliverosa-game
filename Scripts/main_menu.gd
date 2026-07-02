extends TextureRect

@export var NEW_GAME_SCENE : PackedScene 
@export var EDITOR_SCENE : PackedScene 


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(NEW_GAME_SCENE)

func _on_settings_pressed() -> void:
	PauseManager.show_settings_menu()

func _on_editor_pressed() -> void:
	AudioManager.play_editor_music()
	get_tree().change_scene_to_packed(EDITOR_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
