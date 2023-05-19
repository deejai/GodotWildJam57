extends Node2D

class_name LandingSurface

enum Type {BOUNCER, SLIDER, SAFE, WATER}

@export var effective_area: Area2D
@export var priority: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
