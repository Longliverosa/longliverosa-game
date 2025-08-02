extends Sprite2D
class_name Companion

@export var power_slot_scene: PackedScene = preload("res://Scenes/Player/PowerSlot.tscn")
@onready var eye_platform_scene: PackedScene = preload("res://Scenes/Player/eyeplatform.tscn")
@onready var pepper_animations: AnimationPlayer = $PepperAnimations
@onready var raycast: RayCast2D = $"../RayCast2D"
@onready var plug: Line2D = $"../Plug"
@onready var plug_head: Sprite2D = $"../PlugHead"
@onready var select_power_ui: Node = $"../SelectPower"
@onready var select_power_sprite: Node = $"../SelectPowerBg"
@onready var player_body: CharacterBody2D = get_parent()
@onready var camera: Camera2D = $"../Camera2D"
@onready var subcamera: Camera2D = $Camera2D
@onready var player_sprite: Sprite2D = $"../Sprite2D"
@onready var fuel_bar: ProgressBar = $FuelBar
@onready var fuel_label: Label = $FuelLabel

var equipped_power_ids: Array = []
var power_list: Array = []
var power_ui_nodes: Array = []
var current_index: int = 0
var controlling: bool = false
var max_fuel: float = 5.0
var boost_multiplier: float = 2.0
var fuel: float = max_fuel
var follow_speed: float = 2.0
var fluff_radius: float = 0.3

const PLUG_SPEED: float = 300.0
const ENEMY_PULL_SPEED: float = 200.0
const PLUG_RANGE: float = 300.0

signal power_changed(power)

func initialize(equipped_ids: Array) -> void:
	equipped_power_ids = equipped_ids

func _ready():
	scale = Vector2(0.5, 0.5)
	if equipped_power_ids.is_empty():
		equipped_power_ids = ["basic_attack", "destroy_blocks", "remote_control", "create_platforms", "grappling_hook", "freeze_time"]

	for id in equipped_power_ids:
		var power = _create_power_instance(id)
		if power:
			power_list.append(power)

	_build_power_wheel()
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

	for power in power_list:
		power.update(self, delta)

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

func _set_power(power):
	texture = power.texture
	power.on_select(self)

func get_current_power():
	return power_list[current_index]

func _build_power_wheel():
	for child in select_power_ui.get_children():
		child.queue_free()
	power_ui_nodes.clear()
	var radius = 50.0
	var count = power_list.size()
	for i in range(count):
		var angle = deg_to_rad(-360.0 / count * i - 90) 
		var slot = power_slot_scene.instantiate()
		slot.position = Vector2(cos(angle), sin(angle)) * radius
		slot.set_icon(power_list[i].texture)
		select_power_ui.add_child(slot)
		power_ui_nodes.append(slot)
	_update_highlight()

func _update_highlight():
	for i in range(power_ui_nodes.size()):
		var slot = power_ui_nodes[i]
		var sprite = slot.get_node("Sprite2D")
		if i == current_index:
			sprite.modulate = Color(1, 1, 1)
		else:
			sprite.modulate = Color(0.5, 0.5, 0.5)

func use_power():
	var power = get_current_power()
	if power.can_use(self):
		power.use(self)

func _find_nearest_in_group(group: String, radius: float) -> Node2D:
	var nearest = null
	var nearest_dist = radius
	for node in get_tree().get_nodes_in_group(group):
		var dist = player_body.global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest = node
			nearest_dist = dist
	return nearest

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

func _create_power_instance(id: String) -> Power:
	match id:
		"basic_attack":
			return BasicAttackPower.new()
		"destroy_blocks":
			return DestroyBlocksPower.new()
		"remote_control":
			return RemoteControlPower.new()
		"create_platforms":
			return CreatePlatformsPower.new()
		"grappling_hook":
			return GrapplingHookPower.new()
		"freeze_time":
			return FreezeTimePower.new()
		_:
			return null

func cleanup():
	var power = get_current_power()
	if power and power.has_method("_stop_pulling_enemy"):
		power._stop_pulling_enemy(self)
