extends Sprite2D

var follow_speed: float = 2
var fluff_radius: float = 1
@onready var player = $"../Sprite2D"

func _ready() -> void:
	self.scale = Vector2(0.45, 0.45)

func _process(delta: float) -> void:
	var target_pos = player.position + Vector2(-50, 0) 
	position = position.lerp(target_pos, follow_speed * delta)

	var fluff = Vector2(
		sin(Time.get_ticks_msec() / 200.0),
		cos(Time.get_ticks_msec() / 300.0)
	) * fluff_radius

	position += fluff
