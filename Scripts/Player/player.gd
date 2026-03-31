class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var gravity: int= 1000
@export var jump_height: int = 52
@export var max_speed: int = 200
@export var acceleration: float = 0.06
@export var friction: float = 0.15
@export var slow_walk_multiplier: float = 0.4
@export var water_gravity: int = 200
@export var water_drag: float = 0.1

@onready var label: Label = $Canvas/Label
@onready var shield_slider: HSlider = $Canvas/ShieldSlider
@onready var select_power: Node = $SelectPower
@onready var select_power_sprite: Node = $"SelectPowerBg"
@onready var coyote_timer: Timer = $Timers/CoyoteTime
@onready var jump_buffer: Timer = $Timers/JumpBuffer
@onready var shield_cooldown : Timer = $Timers/ShieldCooldown
@onready var damage_cooldown : Timer = $Timers/DamageCooldown
@onready var companion_scene = preload("res://Scenes/Player/companion.tscn")
@onready var companion = companion_scene.instantiate()
@onready var GFX = $GFX

var current_checkpoint_pos: Vector2
var impulse_velocity: Vector2 = Vector2.ZERO

var controlling: bool = false
var dialogue_active:bool = false
var has_shield: bool = true
var grappling: bool = false
var can_fall: bool = true
var is_forced_slow: bool = false
var is_dodging: bool = false

var shortcut_map = {
	"orange_shortcut": 0,
	"yellow_shortcut": 1,
	"blue_shortcut": 2,
	"purple_shortcut": 3,
	"green_shortcut": 4
}

func _ready():
	companion.initialize(["basic_attack", "remote_control", "grappling_hook", "create_platforms", "freeze_time"])
	get_parent().add_child.call_deferred(companion)
	companion.power_changed.connect(_on_power_changed)
	_on_power_changed(companion.get_current_power())
	current_checkpoint_pos = global_position

func _physics_process(delta):
	if select_power.visible or controlling:
		return
	
	var map_pos = $"../TileMapLayer".local_to_map(global_position)
	var tile_data = $"../TileMapLayer".get_cell_tile_data(map_pos) # Layer 0
	var in_water = tile_data.get_custom_data("is_water") if tile_data else false

	if in_water:
		velocity.y += water_gravity * delta
		velocity.x = lerp(velocity.x, 0.0, water_drag) # Simulate thick water
		# Add swimming jump logic here if needed
	elif not is_on_floor() and can_fall:
		velocity.y += gravity * delta
	else:
		coyote_timer.start()

	if Input.is_action_just_pressed("jump") and not dialogue_active:
		if in_water:
			velocity.y = -sqrt(jump_height * 2 * water_gravity)
		else:
			jump_buffer.start()

	if !jump_buffer.is_stopped() and !coyote_timer.is_stopped():
		velocity.y = -sqrt(jump_height * 2 * gravity)
		coyote_timer.stop()
		jump_buffer.stop()

	var direction = Input.get_axis("move_left", "move_right")
	var current_speed = max_speed
	if is_forced_slow:
		current_speed *= slow_walk_multiplier
	if is_dodging:
		current_speed *= 2.0 # Dodge speed boost
	if direction and not dialogue_active:
		velocity.x = lerp(velocity.x, direction * current_speed, acceleration)
		if(velocity.x < 0):
			GFX.flip_h = true
		else:
			GFX.flip_h = false
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
		
	if impulse_velocity != Vector2.ZERO:
		velocity += impulse_velocity
		impulse_velocity = Vector2.ZERO
		print(velocity.y)
	var has_collisions = move_and_slide()
	if has_collisions: 
		var last_collision = get_last_slide_collision()
		var collider = last_collision.get_collider()
		if(collider.is_in_group("damage_player") and not collider.get_parent().fainted):
			var collision_normal = last_collision.get_normal()
			if collision_normal.y < -0.5 and collider.get_parent().is_stunned: # -0.5 means hitting from above
				collider.get_parent().die_from_jump()
				velocity.y = -sqrt(jump_height * 1 * gravity) # Small bounce for Rosa
			else:
				damage(global_position.angle_to_point(Vector2(collider.global_position.x, collider.global_position.y - 20)))
	
func perform_dodge():
	if is_dodging: return
	is_dodging = true
	await get_tree().create_timer(0.2).timeout 
	is_dodging = false

func _process(_delta: float) -> void:
	if !shield_cooldown.is_stopped():
		shield_slider.value = shield_cooldown.time_left / 10.0 * 100.0
	elif !has_shield:
		shield_slider.visible = false
		has_shield = true

func _input(_event):
	if Input.is_action_just_pressed("menu") and !controlling:
		if companion.equipped_power_ids.size() > 1:
			select_power.visible = not select_power.visible
			select_power_sprite.visible = not select_power_sprite.visible
		else:
			print("Only one power unlocked - Wheel disabled")
		select_power.visible = not select_power.visible
		select_power_sprite.visible = not select_power_sprite.visible
	
	if Input.is_action_just_pressed("dodge"):
		perform_dodge()
	
	if select_power.visible:
		if Input.is_action_just_pressed("ui_right"):
			companion.prev_power()
		if Input.is_action_just_pressed("ui_left"):
			companion.next_power()

		for shortcut_action in shortcut_map.keys():
			if Input.is_action_just_pressed(shortcut_action):
				companion.set_power_by_index(shortcut_map[shortcut_action])

		if Input.is_action_just_released("pepper_power") and $Timers/CompanionCooldown.time_left==0:
			select_power.hide()
			select_power_sprite.hide()
			companion.cleanup()
	else:
		if Input.is_action_just_released("pepper_power") and $Timers/CompanionCooldown.time_left==0:
			companion.use_power()
			

func damage(angle: float) -> void:
	if has_shield:
		has_shield = false
		shield_slider.visible = true
		shield_cooldown.start()
		damage_cooldown.start()
		
		var direction_vector = Vector2(-cos(angle), sin(angle)).normalized() 
		impulse_velocity = Vector2(direction_vector.x * 400, direction_vector.y * (-300 if is_on_floor() else -800)) 
	elif damage_cooldown.is_stopped() or is_dodging:
		reset_to_checkpoint()

func reset_to_checkpoint():
	print("RESET TO CHECKPOINT")
	global_position = current_checkpoint_pos
	has_shield = true
	velocity = Vector2.ZERO
	shield_cooldown.stop()
	shield_slider.visible = false

func _on_power_changed(power):
	label.text = power["text"]
