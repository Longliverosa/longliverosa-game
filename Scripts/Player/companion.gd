extends CharacterBody2D
class_name Companion

@export var power_slot_scene: PackedScene = preload("res://Scenes/Player/PowerSlot.tscn")
@onready var eye_platform_scene: PackedScene = preload("res://Scenes/Player/eyeplatform.tscn")
@onready var pepper_animations: AnimationPlayer = $PepperAnimations
@onready var subcamera: Camera2D = $Camera2D
@onready var fuel_bar: ProgressBar = $FuelBar
@onready var fuel_label: Label = $FuelLabel
@onready var sprite: Sprite2D = $GFX
@onready var crosshair: Sprite2D = $Crosshair

@onready var player_body: CharacterBody2D = get_parent().get_node("Player")
@onready var camera: Camera2D = $"../Player/Camera2D"
@onready var player_sprite: Sprite2D = $"../Player/GFX"
@onready var player_collider: CollisionShape2D = $"../Player/CollisionShape2D"
@onready var raycast: RayCast2D = $"../Player/RayCast2D"
@onready var plug: Line2D = $"../Player/Plug"
@onready var plug_head: Sprite2D = $"../Player/PlugHead"
@onready var select_power_ui: Node = $"../Player/SelectPower"
@onready var select_power_sprite: Node = $"../Player/SelectPowerBg"

var equipped_power_ids: Array = []
var power_list: Array = []
var power_ui_nodes: Array = []
var current_index: int = 0
var controlling: bool = false
var max_fuel: float = 5.0
var boost_multiplier: float = 2.0
var fuel: float = max_fuel
@export var follow_speed: float = 0.5
var fluff_radius: float = 0.3
var is_attacking: bool = false

const PLUG_SPEED: float = 300.0
const ENEMY_PULL_SPEED: float = 200.0
const PLUG_RANGE: float = 30.0
const BASIC_ATTACK_RANGE = 150.0

const CROSSHAIR_OFFSET = Vector2(0, -24)
const CROSSHAIR_COLORS = {
	"grappling_hook": Color(0, 1, 0),
	"basic_attack": Color(1, 0, 0),
	"destroy_blocks": Color(1, 1, 0)
}

signal power_changed(power)

func initialize(equipped_ids: Array) -> void:
	equipped_power_ids = equipped_ids
	for id in equipped_power_ids:
		var power = _create_power_instance(id)
		if power:
			power_list.append(power)

func _ready():
	if equipped_power_ids.is_empty():
		initialize(["basic_attack", "destroy_blocks", "remote_control", "create_platforms", "grappling_hook", "freeze_time"])
	
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
	crosshair.visible = false

func _physics_process(delta: float) -> void:
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
			velocity = dir.normalized() * speed
			move_and_slide()
			fuel -= drain * delta
		else:
			controlling = false
			player_body.controlling = false
			camera.enabled = true
			subcamera.enabled = false
			fuel = max_fuel
			fuel_bar.visible = false
			get_node("CollisionShape2D").disabled = true
	else:
		var target_position = player_sprite.global_position  
		var current_target_distance = global_position.distance_to(target_position)
		if current_target_distance > 30 and !is_attacking:
			global_position = global_position.lerp(target_position, follow_speed * delta)
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
	_update_crosshair()

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
	sprite.texture = power.texture
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
		var wheel_sprite = slot.get_node("Sprite2D")
		if i == current_index:
			wheel_sprite.modulate = Color(1, 1, 1)
		else:
			wheel_sprite.modulate = Color(0.5, 0.5, 0.5)

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

func _find_nearest_in_groups(groups: Array, radius: float) -> Node2D:
	var nearest = null
	var nearest_dist = radius
	for group in groups:
		for node in get_tree().get_nodes_in_group(group):
			var dist = player_body.global_position.distance_to(node.global_position)
			if dist < nearest_dist:
				nearest = node
				nearest_dist = dist
	return nearest

func _update_crosshair():
	var power = get_current_power()
	if not power:
		crosshair.visible = false
		return
	var target = null
	var color = Color(1, 1, 1)
	match power.id:
		"grappling_hook":
			target = _find_nearest_in_groups(["hookable", "pullable"], PLUG_RANGE)
			color = CROSSHAIR_COLORS["grappling_hook"]
		"basic_attack":
			target = _find_nearest_in_group("attackable", BASIC_ATTACK_RANGE)
			color = CROSSHAIR_COLORS["basic_attack"]
		"destroy_blocks":
			target = _find_nearest_in_group("breakable", PLUG_RANGE)
			color = CROSSHAIR_COLORS["destroy_blocks"]
		_:
			target = null
	if target:
		crosshair.visible = true
		crosshair.global_position = target.global_position + CROSSHAIR_OFFSET
		crosshair.modulate = color
	else:
		crosshair.visible = false

func _attack_or_break_nearest(group: String, radius: float = 200):
	var target = _find_nearest_in_group(group, radius)
	is_attacking = true
	if target:
		match group:
			"breakable":
				pepper_animations.play("YellowAttack")
			"attackable":
				pepper_animations.play("OrangeAttack")

		while target and target.global_position.distance_to(global_position) > 3.0:
			var delta = get_process_delta_time()
			global_position = global_position.lerp(target.global_position, follow_speed * delta)
			await get_tree().process_frame
		if target:
			if group == "breakable":
				target.queue_free()
			elif group == "attackable":
				target.rotation_degrees = 180
				target.fainted = true
	is_attacking = false
	
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
	for power in power_list:
		if power:
			power.on_deselect(self)
