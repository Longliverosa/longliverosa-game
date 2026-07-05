extends Path2D

#Variable from the animation player node in the tree
#This lets us change the speed scale of the animation in here

@export var speed_scale = 1.0
@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer

#When button pressed
func _on_button_pressed():
	#Play the animation of it going down
	animation.play("platform_move_button_controlled")
	#Let the animation speed scale equal our own speed scale which we can change if need be
	animation.speed_scale = speed_scale
	#Wait 3 seconds
	await get_tree().create_timer(3).timeout
	#Now play the animation of it going back up
	animation.play("platform_moveback")
	
#This is code that was supposed to make it move up if the player walked in but it doesnt work
#If you can find out why its not working please fix it
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		animation.play("platform_moveback")
