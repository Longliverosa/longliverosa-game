extends Power
class_name GrapplingHookPower

var grappling: bool = false
var grapple_point: Vector2 = Vector2.ZERO
var pulling_enemy: bool = false
var pulled_enemy: Node2D = null
var hooked_collider: CollisionShape2D = null

const MAX_ROPE_LENGTH := 300.0
const SWING_FORCE := 1100.0

var sprite_active = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test_active.png")
var sprite = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test.png")

func _init():
	id = "grappling_hook"
	texture = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test.png")
	text = "Current Power: Grappling Hook"

func use(companion):
	if pulling_enemy:
		_stop_pulling_enemy(companion)
		companion.get_node("GFX").texture = sprite
		return
	companion.get_node("GFX").texture = sprite_active
	var enemy = companion._find_nearest_in_group("pullable", companion.PLUG_RANGE)
	var hook = companion._find_nearest_in_group("hookable", companion.PLUG_RANGE)
	if enemy and (not hook or companion.player_body.global_position.distance_to(enemy.global_position) < companion.player_body.global_position.distance_to(hook.global_position)):
		_start_pulling_enemy(companion, enemy)
		return
	if hook:
		companion.raycast.target_position = hook.global_position - companion.player_body.global_position
		companion.raycast.force_raycast_update()
		var collider = companion.raycast.get_collider()
		if not collider or collider == hook:
			grapple_point = hook.global_position
			grappling = true
			hooked_collider = hook.get_node_or_null("CollisionShape2D")
			if hooked_collider:
				hooked_collider.disabled = true

func update(companion, delta):
	if grappling:
		_update_grapple(companion, delta)
	elif pulling_enemy:
		_update_enemy_pull(companion, delta)

func _update_grapple(companion, delta):
	var player = companion.player_body
	companion.global_position = player.global_position
	var player_pos = player.global_position
	var rope_vec = grapple_point - player_pos
	var distance = rope_vec.length()
	if distance > MAX_ROPE_LENGTH:
		_stop_grapple(companion)
		return
	var rope_dir = rope_vec.normalized()
	var tangent = Vector2(-rope_dir.y, rope_dir.x)
	var tangential_speed = player.velocity.dot(tangent)
	player.velocity = tangent * tangential_speed
	var gravity_tangential = Vector2(0, player.gravity).dot(tangent)
	player.velocity += tangent * gravity_tangential * delta
	if Input.is_action_pressed("move_left"):
		player.velocity -= tangent * SWING_FORCE * delta
	if Input.is_action_pressed("move_right"):
		player.velocity += tangent * SWING_FORCE * delta
	player.global_position = grapple_point - rope_dir * distance
	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(grapple_point))
	companion.rotation = rope_vec.angle() + PI + 1.5
	companion.plug_head.global_position = grapple_point
	companion.plug_head.rotation = rope_vec.angle()
	companion.plug_head.show()
	if Input.is_action_just_pressed("jump"):
		companion.get_node("GFX").texture = sprite
		_stop_grapple(companion)

func _start_pulling_enemy(_companion, enemy: Node2D):
	pulled_enemy = enemy
	pulled_enemy.grappled = true
	pulling_enemy = true

func _update_enemy_pull(companion, delta):
	if pulled_enemy.test_move(pulled_enemy.transform, Vector2.ZERO) or pulled_enemy.global_position.distance_to(companion.player_body.global_position) < 40:
		_stop_pulling_enemy(companion)
		companion.get_node("GFX").texture = sprite
		return
	var dir = (companion.global_position - pulled_enemy.global_position).normalized()
	pulled_enemy.global_position += dir * companion.ENEMY_PULL_SPEED * delta
	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(pulled_enemy.global_position))
	companion.rotation = (pulled_enemy.global_position - companion.global_position).angle() + PI + 1.5
	companion.plug_head.global_position = pulled_enemy.global_position
	companion.plug_head.rotation = (pulled_enemy.global_position - companion.global_position).angle()
	companion.plug_head.show()

func _stop_pulling_enemy(companion):
	pulling_enemy = false
	if pulled_enemy:
		pulled_enemy.grappled = false
		pulled_enemy.start_x = pulled_enemy.global_position.x
		pulled_enemy = null
	companion.plug.clear_points()
	companion.plug_head.hide()
	companion.rotation = 0

func _stop_grapple(companion):
	grappling = false
	companion.rotation = 0
	companion.plug.clear_points()
	companion.plug_head.hide()
	if hooked_collider:
		hooked_collider.disabled = false
		hooked_collider = null

func on_deselect(companion):
	_stop_pulling_enemy(companion)
	_stop_grapple(companion)
