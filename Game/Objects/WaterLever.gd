extends Node2D

class_name WaterLever

var is_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func flip():
	is_on = !is_on
	Main.set_ground_water(is_on)
	if is_on:
		$AnimatedSprite2D.animation = "on"
	else:
		$AnimatedSprite2D.animation = "off"
