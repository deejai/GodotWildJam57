extends Node2D

const DEATH_DELAY_TIME: float = 3.0
var death_delay: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(Main.player) or Main.game_over:
		death_delay -= delta
		modulate.a = death_delay / DEATH_DELAY_TIME
		
		if death_delay <= 0.0:
			queue_free()
	else:
		rotation = position.angle_to_point(Main.player.position)
		if position.distance_squared_to(Main.player.position) > 25.0:
			position += position.direction_to(Main.player.position) * 200.0 * delta
		else:
			var skelly = load("res://Game/Objects/Skelly.tscn").instantiate()
			skelly.position = Main.player.position
			get_parent().add_child(skelly)
			Main.player.queue_free()
