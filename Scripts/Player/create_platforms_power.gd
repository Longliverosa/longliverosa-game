extends Power
class_name CreatePlatformsPower

var charge_time: float = 0.0
var charge_ready: bool = false
var active_platform: Node2D = null
var preview_sprite: Sprite2D = null

const REQUIRED_CHARGE: float = 0.8
const OFFSET_Y := 8
const HORIZONTAL_OFFSET := 48
const VERTICAL_OFFSET := 32
const PREVIEW_TEXTURE := preload("res://Assets/Sprites/Characters/Peppers/eyeblock.png")

func _init():
	id = "create_platforms"
	texture = preload("res://Assets/Sprites/Characters/Peppers/spr_purple_pepper_test.png")
	text = "Current Power: Creates Platform"

func use(companion):
	if not charge_ready:
		return
	if active_platform:
		active_platform.queue_free()
		active_platform = null

	companion.pepper_animations.play("PurpleHaze")
	var platform = companion.eye_platform_scene.instantiate()
	companion.player_body.get_parent().add_child(platform)

	var target_pos = _get_target_position(companion)
	platform.global_position = target_pos
	platform.rotation = companion.rotation

	if _is_vertical():
		companion.player_body.global_position.y = platform.global_position.y - OFFSET_Y

	active_platform = platform
	charge_time = 0.0
	charge_ready = false

func update(companion, delta):
	if companion.get_current_power() != self:
		if preview_sprite:
			preview_sprite.queue_free()
			preview_sprite = null
		return

	var on_ground = false
	if companion.player_body.is_on_floor():
		var collision = companion.player_body.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider == null or not collider.is_in_group("ungrounded"):
				on_ground = true
		else:
			on_ground = true

	if not charge_ready and on_ground:
		charge_time = clamp(charge_time + delta, 0, REQUIRED_CHARGE)
		if charge_time >= REQUIRED_CHARGE:
			charge_ready = true

	if charge_ready:
		var pos = _get_target_position(companion)
		if not preview_sprite:
			preview_sprite = Sprite2D.new()
			preview_sprite.texture = PREVIEW_TEXTURE
			preview_sprite.modulate = Color(1, 1, 1, 0.3)
			companion.player_body.get_parent().add_child(preview_sprite)
		preview_sprite.global_position = pos
		preview_sprite.rotation = companion.rotation
	else:
		if preview_sprite:
			preview_sprite.queue_free()
			preview_sprite = null

func on_deselect(companion):
	companion.rotation = 0
	if preview_sprite:
		preview_sprite.queue_free()
		preview_sprite = null

func _get_target_position(companion) -> Vector2:
	var player_pos = companion.player_body.global_position
	if Input.is_action_pressed("move_up"):
		companion.rotation = 0
		return Vector2(player_pos.x, player_pos.y - VERTICAL_OFFSET)
	else:
		var dir := 1.0
		if Input.is_action_pressed("move_left"):
			dir = -1.0
		elif Input.is_action_pressed("move_right"):
			dir = 1.0
		companion.rotation = PI / 2 if dir > 0 else -PI / 2
		return Vector2(player_pos.x + dir * HORIZONTAL_OFFSET, player_pos.y + OFFSET_Y)

func _is_vertical() -> bool:
	return Input.is_action_pressed("move_up") or (
		not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))
