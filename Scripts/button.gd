extends Area2D

signal pressed
signal released

@export var is_toggle : bool = true
@export var press_duration : float = 0.5

@onready var sprite_inactive : Sprite2D = $Sprite2D
@onready var sprite_active : Sprite2D = $Sprite2D_ACTIVE
@onready var label : Label = $Label
@onready var timer : Timer = $Timer
@onready var buzz_sound : Resource = preload("res://Assets/Sounds/effects/negative_buzzer_sound.mp3")

var pressed_bodies: Array = []

var is_active : bool = false
var is_pressable : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_pressable and is_toggle:
			set_pressed(not is_active)
		elif is_pressable and not is_active:
			set_pressed(true)
			timer.wait_time = press_duration if press_duration >= 0.5 else 0.5 
			timer.start()
		else:
			AudioManager.play_effect(buzz_sound)
			
func _on_timer_timeout() -> void:
	set_pressed(false)

func set_pressed(is_pressed: bool) -> void:
	is_active = is_pressed
	sprite_inactive.visible = not is_pressed
	sprite_active.visible = is_pressed
	if is_pressed: 
		pressed.emit()
	else:
		released.emit()

func _on_body_entered(body):
	if body is Player:
		is_pressable = true
		label.visible = true

func _on_body_exited(body):
	if body is Player:
		is_pressable = false
		label.visible = false
