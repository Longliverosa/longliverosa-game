class_name Player
extends CharacterBody2D

@export var gravity = 1000
@export var speed = 200.0
@export var jump_velocity = -300
var platform_count = 0
var cooldown_until = 0

const TEX_ORANGE = preload("res://Sprites/Characters/Peppers/spr_orange_pepper_test.png")
const TEX_YELLOW = preload("res://Sprites/Characters/Peppers/spr_yellow_pepper_test.png")
const TEX_BLUE = preload("res://Sprites/Characters/Peppers/spr_blue_pepper_test.png")
const TEX_PURPLE = preload("res://Sprites/Characters/Peppers/spr_purple_pepper_test.png")
const TEX_GREEN = preload("res://Sprites/Characters/Peppers/spr_green_pepper_test.png")
const EYE_PLATFORM = preload("res://Scenes/Player/eyeplatform.tscn")

@onready var companion = $Companion
@onready var label = $Canvas/Label
@onready var select_power = $SelectPower
@onready var pepper_animations = $PepperAnimations

var powers = {
	"SelectPower/OrangeArea": {
		"texture": TEX_ORANGE,
		"text": "Current Power: Basic Attack"
	},
	"SelectPower/YellowArea": {
		"texture": TEX_YELLOW,
		"text": "Current Power: Destroy Blocks"
	},
	"SelectPower/BlueArea": {
		"texture": TEX_BLUE,
		"text": "Current Power: Water Tower"
	},
	"SelectPower/PurpleArea": {
		"texture": TEX_PURPLE,
		"text": "Current Power: Creates Platforms"
	},
	"SelectPower/GreenArea": {
		"texture": TEX_GREEN,
		"text": "Current Power: Grappling Hook"
	}
}

var power_list = [
	{"texture": TEX_ORANGE, "text": "Current Power: Basic Attack"},
	{"texture": TEX_YELLOW, "text": "Current Power: Destroy Blocks"},
	{"texture": TEX_BLUE, "text": "Current Power: Water Tower"},
	{"texture": TEX_PURPLE, "text": "Current Power: Creates Platforms"},
	{"texture": TEX_GREEN, "text": "Current Power: Grappling Hook"}
]
var current_index = 0

func _ready() -> void:
	for node_name in powers.keys():
		var node = get_node(node_name)
		if node:
			node.connect("input_event", Callable(self, "_on_color_input_event").bind(node_name))

func _physics_process(delta):
	if select_power.visible:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("jump") and companion.texture == TEX_PURPLE and not is_on_floor():
		if Time.get_ticks_msec() >= cooldown_until and platform_count < 3:
			_spawn_eye_platform()
			platform_count += 1
			if platform_count >= 3:
				cooldown_until = Time.get_ticks_msec() + 3000  
				platform_count = 0
			else:
				pepper_animations.play("PurpleHaze")

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	move_and_slide()

func _input(_event):
	if Input.is_action_just_pressed("menu"):
		if scale == Vector2(0.5, 0.5):
			scale = Vector2(1, 1)
		select_power.visible = not select_power.visible

	if select_power.visible:
		if Input.is_action_just_pressed("ui_right"):
			current_index = (current_index - 1 + power_list.size()) % power_list.size()

		if Input.is_action_just_pressed("ui_left"):
			current_index = (current_index + 1) % power_list.size()

		if Input.is_action_just_pressed("orange_shortcut"): current_index = 0
		if Input.is_action_just_pressed("yellow_shortcut"): current_index = 1
		if Input.is_action_just_pressed("blue_shortcut"): current_index = 2
		if Input.is_action_just_pressed("purple_shortcut"): current_index = 3
		if Input.is_action_just_pressed("green_shortcut"): current_index = 4

		highlight_power(current_index)

		if Input.is_action_just_pressed("pepper_power"):
			_set_power(power_list[current_index])
	else:
		if Input.is_action_just_pressed("pepper_power"):
			match companion.texture:
				TEX_ORANGE:
					print("orange")
				TEX_BLUE:
					print("blue")
				TEX_GREEN:
					print("green")
				TEX_YELLOW:
					print("yellow")

func _set_power(power):
	companion.texture = power["texture"]
	label.text = power["text"]
	select_power.hide()
	
func highlight_power(current_index):
	var area_names = [
		"OrangeArea",
		"YellowArea",
		"BlueArea",
		"PurpleArea",
		"GreenArea"
	]

	for i in range(area_names.size()):
		var area_node = select_power.get_node(area_names[i])
		if area_node:
			var sprite_name = area_names[i].replace("Area", "Sprite")
			var sprite = area_node.get_node(sprite_name)
			if sprite:
				if i == current_index:
					sprite.modulate = Color(1, 1, 1) 
				else:
					sprite.modulate = Color(0.5, 0.5, 0.5) 
					
func _spawn_eye_platform():
	var platform = EYE_PLATFORM.instantiate()
	get_parent().add_child(platform)
	platform.global_position = Vector2(global_position.x, global_position.y + 8)

func _on_color_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, node_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var power = powers.get(node_name)
		if power:
			_set_power(power)
