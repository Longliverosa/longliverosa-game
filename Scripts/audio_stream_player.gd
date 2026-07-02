extends Node

var menu_music : AudioStream = preload("res://Assets/Sounds/Music/beach_music.mp3")
var editor_music : AudioStream = preload("res://Assets/Sounds/Music/level_editor_wip2.ogg")

@onready var music_stream_player = $MusicStreamPlayer
@onready var effects_stream_player = $EffectsStreamPlayer

func play_music(track: Resource) -> void:
	if not track == music_stream_player.stream:
		music_stream_player.stream = track
		music_stream_player.play()
	
func play_effect(effect: Resource) -> void:
	effects_stream_player.stream = effect
	effects_stream_player.play()

func _on_finished() -> void:
	music_stream_player.play()
