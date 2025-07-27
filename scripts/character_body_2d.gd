extends CharacterBody2D

#This features the basic Godot 4 Movement, other people are working on our main one
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void: 
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event):
	if Input.is_physical_key_pressed(KEY_SHIFT):
		if scale == Vector2(0.5, 0.5):
			scale = Vector2(1, 1) 
		$SelectPower.visible = not $SelectPower.visible
		
	if Input.is_physical_key_pressed(KEY_Z):
		match $"../Companion".texture.resource_path:
			"res://sprites/spr_redp.png":
				print("red")
			"res://sprites/spr_bluep.png":
				$"../PepperAnimations".play("AttackPlaceholder")
				$"Attack Damage Area/CollisionShape2D".disabled = false
				await get_tree().create_timer(0.1).timeout
				$"Attack Damage Area/CollisionShape2D".disabled = true
			"res://sprites/spr_greenp.png":
				print("green")
			"res://sprites/spr_purplep.png":
				print("purple")
			"res://sprites/spr_yellowp.png":
				$"../PepperAnimations".play("ShrinkPlaceholder")
				if scale == Vector2(1, 1):
					scale = Vector2(0.5, 0.5) 
					if $SelectPower.visible:
						$SelectPower.hide()
				else:
					scale = Vector2(1, 1) 
			"res://sprites/spr_greyp.png":
				print("grey")
				
# Tried getting all these signals into one big one but trying to get the variable I needed didn't work initially, if this code gets used I'd def optimize it
func _on_pepper_picked_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_redp.png")
		$"../Canvas/Label".text = "Current Power: Grappling Hook? (Not Implemented)"
		$SelectPower.hide()

func _on_area_2d_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_yellowp.png")
		$"../Canvas/Label".text = "Current Power: Go small?"
		$SelectPower.hide()

func _on_area_2d_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_bluep.png")
		$"../Canvas/Label".text = "Current Power: Break things?"
		$SelectPower.hide()

func _on_area_2d_4_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_greyp.png")
		$"../Canvas/Label".text = "Current Power: Moving Stuff?"
		$SelectPower.hide()

func _on_area_2d_5_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_purplep.png")
		$"../Canvas/Label".text = "Current Power: Dimensions Shifts? (Not implemented)"
		$SelectPower.hide()

func _on_area_2d_6_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$"../Companion".texture = load("res://sprites/spr_greenp.png")
		$"../Canvas/Label".text = "Current Power: Terminal Hacking? (Not Implemented)"
		$SelectPower.hide()

func _on_attack_damage_area_area_entered(area: Area2D) -> void:
	if area.name == "BreakableBlock": 
		area.queue_free()
