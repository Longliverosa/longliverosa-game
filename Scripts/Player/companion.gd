class_name Companion
extends Sprite2D

@export var power_list: Array[Dictionary] = [
	{"texture": preload("res://Sprites/Characters/Peppers/spr_orange_pepper_test.png"), "text": "Current Power: Basic Attack"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_yellow_pepper_test.png"), "text": "Current Power: Destroy Blocks"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_blue_pepper_test.png"), "text": "Current Power: Remote Control"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_purple_pepper_test.png"), "text": "Current Power: Creates Platforms"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_green_pepper_test.png"), "text": "Current Power: Grappling Hook"}
]

@onready var eye_platform_scene: PackedScene = preload("res://Scenes/Player/eyeplatform.tscn")
@onready var pepper_animations: AnimationPlayer = $"../PepperAnimations"
@onready var raycast: RayCast2D = $"../RayCast2D"
@onready var plug: Line2D = $"../Plug"
@onready var plug_head: Sprite2D = $"../PlugHead"
@onready var select_power_ui: Node = $"../SelectPower"
@onready var player_body: CharacterBody2D = get_parent()
@onready var camera: Camera2D = $"../Camera2D"
@onready var subcamera: Camera2D = $Camera2D
@onready var player_sprite: Sprite2D = $"../Sprite2D"
@onready var fuel_bar: ProgressBar = $FuelBar
@onready var fuel_label: Label = $FuelLabel

var current_index: int = 0
var platform_count: int = 0
var cooldown_until: int = 0
var grappling: bool = false
var grapple_point: Vector2 = Vector2.ZERO
var follow_speed: float = 2.0
var fluff_radius: float = 0.3
var controlling: bool = false
var max_fuel: float = 5.0
var boost_multiplier: float = 2.0
var fuel: float = max_fuel
var remote_cooldown: float = 0.0
var remote_cooldown_time: float = 1.5
var pulling_enemy: bool = false
var pulled_enemy: Node2D = null

const PLUG_SPEED: float = 300.0
const ENEMY_PULL_SPEED: float = 200.0
const PLUG_RANGE: float = 300.0

signal power_changed(power_data: Dictionary)

func _ready():
	scale = Vector2(0.5, 0.5)
	_set_power(power_list[current_index])
	emit_signal("power_changed", power_list[current_index])
	_update_highlight()
	fuel_bar.max_value = max_fuel
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(1, 1, 1) 
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0, 0, 0) 
	fuel_bar.add_theme_stylebox_override("background", style_bg)
	fuel_bar.add_theme_stylebox_override("fill", style_fill)

func _process(delta: float) -> void:
	if controlling:
		if fuel > 0:
			var dir = Vector2(
				int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
				int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
			)
			var speed = 200.0
			var drain = 1.0
			if Input.is_action_pressed("menu"):
				speed *= boost_multiplier
				drain *= boost_multiplier
			position += dir.normalized() * speed * delta
			fuel -= drain * delta
		else:
			controlling = false
			player_body.controlling = false
			camera.enabled = true
			subcamera.enabled = false
			fuel = max_fuel
			fuel_bar.visible = false
	else:
		position = position.lerp(player_sprite.position + Vector2(-50,0), follow_speed * delta)
		fuel = clamp(fuel + delta, 0, max_fuel)

	var fluff = Vector2(
		sin(Time.get_ticks_msec() / 200.0),
		cos(Time.get_ticks_msec() / 300.0)
	) * fluff_radius
	position += fluff

	fuel_bar.value = fuel
	fuel_bar.visible = controlling
	fuel_label.visible = controlling
	
	if remote_cooldown > 0:
		remote_cooldown -= delta


func next_power():
	current_index = (current_index + 1) % power_list.size()
	_set_power(power_list[current_index])
	emit_signal("power_changed", power_list[current_index])
	_update_highlight()

func prev_power():
	current_index = (current_index - 1 + power_list.size()) % power_list.size()
	_set_power(power_list[current_index])
	emit_signal("power_changed", power_list[current_index])
	_update_highlight()

func set_power_by_index(index: int):
	if index >= 0 and index < power_list.size():
		current_index = index
		_set_power(power_list[current_index])
		emit_signal("power_changed", power_list[current_index])
		_update_highlight()

func _set_power(power: Dictionary):
	texture = power["texture"]

func get_current_power():
	return power_list[current_index]

func _update_highlight():
	var area_names = [
		"OrangeArea",
		"YellowArea",
		"BlueArea",
		"PurpleArea",
		"GreenArea"
	]
	for i in range(area_names.size()):
		var area_node = select_power_ui.get_node(area_names[i])
		if area_node:
			var sprite_name = area_names[i].replace("Area", "Sprite")
			var sprite = area_node.get_node(sprite_name)
			if sprite:
				if i == current_index:
					sprite.modulate = Color(1, 1, 1)
				else:
					sprite.modulate = Color(0.5, 0.5, 0.5)

func physics_step(_delta):
	if grappling:
		var dir = (grapple_point - player_body.global_position).normalized()
		player_body.velocity = dir * PLUG_SPEED
		global_position = player_body.global_position + Vector2(0, -16)
		rotation = (grapple_point - global_position).angle() + PI + 1.5
		plug.clear_points()
		var start_local = plug.to_local(global_position)
		var end_local = plug.to_local(grapple_point)
		plug.add_point(start_local)
		plug.add_point(end_local)
		plug_head.global_position = grapple_point
		plug_head.rotation = (grapple_point - global_position).angle()
		plug_head.show()
		if player_body.global_position.distance_to(grapple_point) < 10:
			grappling = false
			rotation = 0
			plug.clear_points()
	else:
		if pulling_enemy and pulled_enemy:
			var dir = (global_position - pulled_enemy.global_position).normalized()
			pulled_enemy.global_position += dir * ENEMY_PULL_SPEED * _delta
			plug.clear_points()
			plug.add_point(plug.to_local(global_position))
			plug.add_point(plug.to_local(pulled_enemy.global_position))
			rotation = (pulled_enemy.global_position - global_position).angle() + PI + 1.5
			plug_head.global_position = pulled_enemy.global_position
			plug_head.show()
		else:
			plug_head.hide()
			rotation = 0

func use_power():
	var power_text = get_current_power()["text"]
	match power_text:
		"Current Power: Basic Attack":
			_attack_or_break_nearest("enemy")
		"Current Power: Destroy Blocks":
			_attack_or_break_nearest("breakable")
		"Current Power: Remote Control":
			if remote_cooldown <= 0:
				controlling = !controlling
				player_body.controlling = controlling
				camera.enabled = !controlling
				subcamera.enabled = controlling
				fuel = max_fuel
				fuel_bar.visible = controlling
				fuel_label.visible = controlling
				if !controlling:
					remote_cooldown = remote_cooldown_time
		"Current Power: Creates Platforms":
			_spawn_eye_platform()
		"Current Power: Grappling Hook":
			_start_grapple()

func _attack_or_break_nearest(group: String, radius: float = 200):
	var target = _find_nearest_in_group(group, radius)
	if target:
		match group:
			"breakable":
				pepper_animations.play("YellowAttack")
			"enemy":
				pepper_animations.play("OrangeAttack")
		var timer = 0.0
		while timer < 0.5 and target:
			var delta = get_process_delta_time()
			global_position = global_position.lerp(target.global_position, delta * 5)
			timer += delta
			await get_tree().process_frame
		if target:
			target.queue_free()

func _spawn_eye_platform():
	if Time.get_ticks_msec() >= cooldown_until and platform_count < 3:
		pepper_animations.play("PurpleHaze")
		var platform = eye_platform_scene.instantiate()
		player_body.get_parent().add_child(platform)
		platform.global_position = Vector2(player_body.global_position.x, player_body.global_position.y + 8)
		platform_count += 1
		if platform_count >= 3:
			cooldown_until = Time.get_ticks_msec() + 3000
			platform_count = 0

func _start_grapple():
	if pulling_enemy:
		pulling_enemy = false
		if pulled_enemy:
			pulled_enemy.start_x = pulled_enemy.global_position.x
			pulled_enemy.grappled = false
		pulled_enemy = null
		plug.clear_points()
		plug_head.hide()
		return

	var enemy = _find_nearest_in_group("enemy", PLUG_RANGE)

	var hook = _find_nearest_in_group("hooks", PLUG_RANGE)
	if enemy and (not hook or player_body.global_position.distance_to(enemy.global_position) < player_body.global_position.distance_to(hook.global_position)):
		pulled_enemy = enemy
		pulled_enemy.grappled = true
		pulling_enemy = true
		return

	var nearest_hook = hook
	if not nearest_hook: return
	raycast.target_position = nearest_hook.global_position - player_body.global_position
	raycast.force_raycast_update()
	if not raycast.is_colliding():
		grapple_point = nearest_hook.global_position
		grappling = true


func _find_nearest_in_group(group: String, radius: float) -> Node2D:
	var nearest = null
	var nearest_dist = radius
	for node in get_tree().get_nodes_in_group(group):
		var dist = player_body.global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest = node
			nearest_dist = dist
	return nearest
