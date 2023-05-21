extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Main.pressure_plate_walls.push_back(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
