extends Node2D

@onready var track : Resource = preload("res://Assets/Sounds/Music/lobby_music.mp3")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(track)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
