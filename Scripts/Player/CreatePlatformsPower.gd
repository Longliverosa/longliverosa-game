extends Power
class_name CreatePlatformsPower

var charge_time: float = 0.0
var charge_ready: bool = false
var max_platforms: int = 3
var platforms_spawned: int = 0
var active_platforms: Array = []
const REQUIRED_CHARGE: float = 1.5

func _init():
	id = "create_platforms"
	texture = preload("res://Sprites/Characters/Peppers/spr_purple_pepper_test.png")
	text = "Current Power: Creates Platforms"

func use(companion):
	if not charge_ready:
		return
	if platforms_spawned >= max_platforms:
		return
	if active_platforms.size() >= max_platforms:
		var oldest = active_platforms.pop_front()
		if oldest:
			oldest.queue_free()
	companion.pepper_animations.play("PurpleHaze")
	var platform = companion.eye_platform_scene.instantiate()
	companion.player_body.get_parent().add_child(platform)
	platform.global_position = Vector2(companion.player_body.global_position.x, companion.player_body.global_position.y + 8)
	active_platforms.append(platform)
	platforms_spawned += 1
	if platforms_spawned >= max_platforms:
		charge_time = 0.0
		charge_ready = false
		platforms_spawned = 0

func update(companion, delta):
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
