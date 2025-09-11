class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var gravity: int= 1000
@export var jump_height: int = 52
@export var max_speed: int = 200
@export var acceleration: float = 0.06
@export var friction: float = 0.15
@onready var label: Label = $Canvas/Label
@onready var select_power: Node = $SelectPower
@onready var select_power_sprite: Node = $"SelectPowerBg"
@onready var coyote_timer: Timer = $Timers/CoyoteTime
@onready var jump_buffer: Timer = $Timers/JumpBuffer
@onready var damage_cooldown : Timer = $Timers/DamageCooldown
@onready var companion_scene = preload("res://Scenes/Player/companion.tscn")
@onready var companion = companion_scene.instantiate()
@onready var GFX = $GFX

var controlling: bool = false

var health = 20

var shortcut_map = {
	"orange_shortcut": 0,
	"yellow_shortcut": 1,
	"blue_shortcut": 2,
	"purple_shortcut": 3,
	"green_shortcut": 4
}

func _ready():
	companion.initialize(["basic_attack", "remote_control", "grappling_hook", "create_platforms", "destroy_blocks", "freeze_time"])
	get_parent().add_child.call_deferred(companion)
	companion.power_changed.connect(_on_power_changed)
	_on_power_changed(companion.get_current_power())

func _physics_process(delta):
	if select_power.visible or controlling:
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
		if(velocity.x < 0):
			GFX.flip_h = true
		else:
			GFX.flip_h = false
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	var has_collisions = move_and_slide()
	if has_collisions: 
		var last_collision = get_last_slide_collision()
		var collider = last_collision.get_collider()
		if(collider.is_in_group("attackable")):
			damage(1)
			print(health)
	

func _input(_event):
	if Input.is_action_just_pressed("menu") and !controlling:
		select_power.visible = not select_power.visible
		select_power_sprite.visible = not select_power_sprite.visible

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
			select_power_sprite.hide()
			companion.cleanup()
	else:
		if Input.is_action_just_pressed("pepper_power"):
			companion.use_power()

func damage(damage: float) -> void:
	if !damage_cooldown.is_stopped():
		return
	health -= damage
	if(health <= 0):
		reset_to_checkpoint()
	damage_cooldown.start()

func reset_to_checkpoint():
	print("RESET TO CHECKPOINT")
	health = 20

func _on_power_changed(power):
	label.text = power["text"]
