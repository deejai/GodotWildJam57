extends Node2D

class_name LandingSurface

enum Type {CUSHION, BOUNCER, SLIDER, WATER, FIRE, PRESSURE_PLATE}

@export var type: Type
@export var priority: int
@export var active: bool = true

const area_rect: Rect2 = Rect2(-32, -32, 64, 64)

var static_body: StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if type == Type.WATER:
		static_body = $StaticBody2D
		set_active(active)
	Main.object_registry.register_landing_surface(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func has_point(point: Vector2):
	return area_rect.has_point(point - position)

func set_active(is_active: bool):
	if is_active:
		active = true
		visible = true
		static_body.collision_layer = 0b1
		static_body.collision_mask = 0b1
	else:
		active = false
		visible = false
		static_body.collision_layer = 0b0
		static_body.collision_mask = 0b0
