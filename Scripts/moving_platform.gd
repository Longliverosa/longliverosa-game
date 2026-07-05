extends Path2D

#Variables from the various nodes in the tree

#This is from Path2D and it is used to check whether or not the platform should go back and forth or if its a closed loop
@export var loop = true

#This is from animation player and will be used to control its speed scale
@export var speed_scale = 1.0

#This will just control the speed of the animation
@export var speed = 2.0

@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#If loop is checked off
	if not loop:
		#Play the animation of the platform moving back and forth
		animation.play("platform_move")
		#Set speedscale to the speedscale in the code
		animation.speed_scale = speed_scale
		set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	#If not that means the platform is a closed loop
	#In this scenario we'll just increase path.progress by our speed variable
	path.progress += speed
