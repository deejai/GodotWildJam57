extends Node2D

class_name LandingSurface

enum Type {CUSHION, BOUNCER, SLIDER, WATER, FIRE}

@export var type: Type
@export var priority: int

const area_rect: Rect2 = Rect2(-32, -32, 64, 64)

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.object_registry.register_landing_surface(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func has_point(point: Vector2):
	return area_rect.has_point(point - position)
