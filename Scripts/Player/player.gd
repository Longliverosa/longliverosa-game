class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var gravity = 1000
@export var jump_height = 52
@export var max_speed = 200.0
@export var acceleration = 0.06
@export var friction = 0.15
@onready var label = $Canvas/Label
@onready var select_power = $SelectPower
@onready var coyote_timer = $Timers/CoyoteTime
@onready var jump_buffer = $Timers/JumpBuffer
@onready var companion = $Companion

var shortcut_map = {
	"orange_shortcut": 0,
	"yellow_shortcut": 1,
	"blue_shortcut": 2,
	"purple_shortcut": 3,
	"green_shortcut": 4
}

func _ready():
	companion.power_changed.connect(_on_power_changed)
	_on_power_changed(companion.get_current_power())

func _physics_process(delta):
	if select_power.visible:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_timer.start()

	if Input.is_action_just_pressed("jump"):
		jump_buffer.start()

	if !jump_buffer.is_stopped() and !coyote_timer.is_stopped():
		velocity.y = -sqrt(jump_height * 2 * gravity)
		coyote_timer.stop()
		jump_buffer.stop()

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(velocity.x, direction * max_speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	companion.physics_step(delta)
	move_and_slide()

func _input(_event):
	if Input.is_action_just_pressed("menu"):
		select_power.visible = not select_power.visible

	if select_power.visible:
		if Input.is_action_just_pressed("ui_right"):
			companion.prev_power()
		if Input.is_action_just_pressed("ui_left"):
			companion.next_power()

		for shortcut_action in shortcut_map.keys():
			if Input.is_action_just_pressed(shortcut_action):
				companion.set_power_by_index(shortcut_map[shortcut_action])

		if Input.is_action_just_pressed("pepper_power"):
			select_power.hide()
	else:
		if Input.is_action_just_pressed("pepper_power"):
			companion.use_power()

func _on_power_changed(power):
	label.text = power["text"]
