extends Node

var can_pause : bool = false
var paused : bool = false

@onready var pause_menu : Control = $PauseMenu/CanvasLayer/Menu
@onready var background : Control = $PauseMenu/CanvasLayer/Background
@onready var settings_menu : Control = $PauseMenu/CanvasLayer/SettingsMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_pausable(pausable: bool) -> void:
	can_pause = pausable

func show_settings_menu() -> void:
	pause_menu.hide()
	background.show()
	settings_menu.show()

func _process(_delta: float) -> void:
	if can_pause and Input.is_action_just_pressed("pause"):
		paused = !paused
		set_paused(paused)

func back_from_settings() -> void:
	if(can_pause):
		pause_menu.show()
	else:
		background.hide()

func set_paused(is_paused: bool) -> void:
	get_tree().paused = is_paused
	paused = is_paused
	if(paused):
		pause_menu.show()
		background.show()
	else:
		pause_menu.hide()
		background.hide()
		settings_menu.hide()
