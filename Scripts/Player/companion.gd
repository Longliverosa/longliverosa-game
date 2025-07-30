class_name Companion
extends Sprite2D

@export var power_list = [
	{"texture": preload("res://Sprites/Characters/Peppers/spr_orange_pepper_test.png"), "text": "Current Power: Basic Attack"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_yellow_pepper_test.png"), "text": "Current Power: Destroy Blocks"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_blue_pepper_test.png"), "text": "Current Power: Water Tower"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_purple_pepper_test.png"), "text": "Current Power: Creates Platforms"},
	{"texture": preload("res://Sprites/Characters/Peppers/spr_green_pepper_test.png"), "text": "Current Power: Grappling Hook"}
]

@onready var eye_platform_scene = preload("res://Scenes/Player/eyeplatform.tscn")
@onready var pepper_animations = $"../PepperAnimations"
@onready var raycast = $"../RayCast2D"
@onready var plug = $"../Plug"
@onready var plug_head = $"../PlugHead"
@onready var select_power_ui = $"../SelectPower"
@onready var player_body = get_parent()
@onready var player_sprite = $"../Sprite2D"

var current_index = 0
var platform_count = 0
var cooldown_until = 0
var grappling = false
var grapple_point = Vector2.ZERO

const PLUG_SPEED = 300
const PLUG_RANGE = 300

var follow_speed: float = 2
var fluff_radius: float = 0.3

signal power_changed(power_data: Dictionary)

func _ready():
	scale = Vector2(0.5, 0.5)
	_set_power(power_list[current_index])
	emit_signal("power_changed", power_list[current_index])
	_update_highlight()

func _process(delta: float) -> void:
	var target_pos = player_sprite.position + Vector2(-50, 0)
	position = position.lerp(target_pos, follow_speed * delta)

	var fluff = Vector2(
		sin(Time.get_ticks_msec() / 200.0),
		cos(Time.get_ticks_msec() / 300.0)
	) * fluff_radius

	position += fluff

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
		plug_head.hide()
		rotation = 0

func use_power():
	var power_text = get_current_power()["text"]
	match power_text:
		"Current Power: Basic Attack":
			_attack_or_break_nearest("enemy")
		"Current Power: Destroy Blocks":
			_attack_or_break_nearest("breakable")
		"Current Power: Water Tower":
			pass
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
	var nearest_hook = _find_nearest_in_group("hooks", PLUG_RANGE)
	if not nearest_hook:
		return
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
