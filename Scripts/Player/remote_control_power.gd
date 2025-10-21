extends Power
class_name RemoteControlPower

var cooldown: float = 0.0
var cooldown_time: float = 2.5
var sprite_charging: Texture2D = preload("res://Assets/Sprites/Characters/Peppers/spr_grey_pepper_test_charging.png")
var sprite_normal: Texture2D = preload("res://Assets/Sprites/Characters/Peppers/spr_grey_pepper_test.png")
var magnet_speed: float = 150.0
var raycast: RayCast2D

func _init():
	id = "remote_control"
	texture = preload("res://Assets/Sprites/Characters/Peppers/spr_grey_pepper_test.png")
	text = "Current Power: Remote Control"

func use(companion):
	if cooldown <= 0:
		companion.sprite.texture = sprite_normal
		companion.controlling = !companion.controlling
		companion.player_body.controlling = companion.controlling
		companion.camera.enabled = !companion.controlling
		companion.subcamera.enabled = companion.controlling
		companion.fuel = companion.max_fuel
		companion.fuel_bar.visible = companion.controlling
		companion.fuel_label.visible = companion.controlling
		companion.get_node("CollisionShape2D").disabled = not companion.controlling
		if not companion.controlling:
			cooldown = cooldown_time
	else:
		companion.sprite.texture = sprite_charging

func update(companion, delta):
	if cooldown > 0:
		cooldown -= delta
	if companion.controlling:
		var magnet_target = _find_nearest_magnetizable(companion, 200)
		if magnet_target and _has_line_of_sight(companion, magnet_target):
			var dir = (companion.global_position - magnet_target.global_position).normalized()
			magnet_target.global_position += dir * magnet_speed * delta

func _find_nearest_magnetizable(companion, radius: float):
	var nearest = null
	var nearest_dist = radius
	for node in companion.get_tree().get_nodes_in_group("magnetizable"):
		var dist = companion.global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest = node
			nearest_dist = dist
	return nearest

func _has_line_of_sight(companion, target):
	if raycast == null:
		raycast = RayCast2D.new()
		companion.add_child(raycast)
	raycast.enabled = true
	raycast.global_position = companion.global_position
	raycast.target_position = target.global_position - companion.global_position
	raycast.exclude_parent = true
	raycast.add_exception(companion)
	raycast.add_exception(target)
	raycast.force_raycast_update()
	return not raycast.is_colliding()
