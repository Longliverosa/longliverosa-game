extends Node

var menu_music : AudioStream = preload("res://Assets/Sounds/Music/beach_music.mp3")
var editor_music : AudioStream = preload("res://Assets/Sounds/Music/level_editor_wip2.ogg")

@onready var stream_player = $AudioStreamPlayer

func play_menu_music():
	stream_player.stream = menu_music
	stream_player.play()
	
func play_editor_music():
	stream_player.stream = editor_music
	stream_player.play()

func _on_finished() -> void:
	stream_player.play()
