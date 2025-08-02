extends Power
class_name GrapplingHookPower

var grappling: bool = false
var grapple_point: Vector2 = Vector2.ZERO
var pulling_enemy: bool = false
var pulled_enemy: Node2D = null

func _init():
	id = "grappling_hook"
	texture = preload("res://Sprites/Characters/Peppers/spr_green_pepper_test.png")
	text = "Current Power: Grappling Hook"

func use(companion):
	if pulling_enemy:
		_stop_pulling_enemy(companion)
		return
	var enemy = companion._find_nearest_in_group("enemy", companion.PLUG_RANGE)
	var hook = companion._find_nearest_in_group("hooks", companion.PLUG_RANGE)
	if enemy and (not hook or companion.player_body.global_position.distance_to(enemy.global_position) < companion.player_body.global_position.distance_to(hook.global_position)):
		_start_pulling_enemy(companion, enemy)
		return
	if hook:
		companion.raycast.target_position = hook.global_position - companion.player_body.global_position
		companion.raycast.force_raycast_update()
		if not companion.raycast.is_colliding():
			grapple_point = hook.global_position
			grappling = true

func update(companion, delta):
	if grappling:
		_update_grapple(companion, delta)
	elif pulling_enemy:
		_update_enemy_pull(companion, delta)

func _update_grapple(companion, _delta):
	var dir = (grapple_point - companion.player_body.global_position).normalized()
	companion.player_body.velocity = dir * companion.PLUG_SPEED
	companion.global_position = companion.player_body.global_position + Vector2(0, -16)
	companion.rotation = (grapple_point - companion.global_position).angle() + PI + 1.5
	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(grapple_point))
	companion.plug_head.global_position = grapple_point
	companion.plug_head.rotation = (grapple_point - companion.global_position).angle()
	companion.plug_head.show()
	if companion.player_body.global_position.distance_to(grapple_point) < 10:
		grappling = false
		companion.rotation = 0
		companion.plug.clear_points()
		companion.plug_head.hide()

func _start_pulling_enemy(_companion, enemy: Node2D):
	pulled_enemy = enemy
	pulled_enemy.grappled = true
	pulling_enemy = true

func _update_enemy_pull(companion, delta):
	if pulled_enemy.test_move(pulled_enemy.transform, Vector2.ZERO) or pulled_enemy.global_position.distance_to(companion.player_body.global_position) < 40:
		_stop_pulling_enemy(companion)
		return
	var dir = (companion.global_position - pulled_enemy.global_position).normalized()
	pulled_enemy.global_position += dir * companion.ENEMY_PULL_SPEED * delta
	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(pulled_enemy.global_position))
	companion.rotation = (pulled_enemy.global_position - companion.global_position).angle() + PI + 1.5
	companion.plug_head.global_position = pulled_enemy.global_position
	companion.plug_head.show()

func _stop_pulling_enemy(companion):
	pulling_enemy = false
	if pulled_enemy:
		pulled_enemy.grappled = false
		pulled_enemy = null
	companion.plug.clear_points()
	companion.plug_head.hide()
	companion.rotation = 0
