extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(Main.player) or Main.game_over:
		queue_free()
	else:
		rotation = position.angle_to_point(Main.player.position)
		if position.distance_squared_to(Main.player.position) > 100.0:
			position += position.direction_to(Main.player.position) * 200.0 * delta
