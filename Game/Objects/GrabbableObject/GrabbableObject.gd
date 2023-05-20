extends Node2D

class_name GrabbableObject

const collision_layer_bits = 0b1 | 0b100
const collision_mask_bits = 0b1

@export var is_throwable: bool = false
@export var is_breakable: bool = true

@export var sprite: Sprite2D
var original_sprite_scale: Vector2

@export var static_body: StaticBody2D

enum State {GROUNDED, GRABBED, THROWN, SLIDING}
var state: State = State.GROUNDED

enum Impact {SOFT, HARD}

var flight_velocity: Vector2 = Vector2.ZERO
var total_flight_duration: float = 0.0
var flight_time_elapsed: float = 0.0

var sliding_bounds_origin: Vector2
var sliding_bounds_rect: Rect2

func land(impact: Impact):
	var landing_surface: LandingSurface = Main.object_registry.get_landing_surface_at_point(position)

	if impact == Impact.HARD and is_breakable and (landing_surface == null or landing_surface.type != LandingSurface.Type.CUSHION):
		queue_free()
		var kabloom = load("res://Game/Objects/Kablam.tscn").instantiate()
		kabloom.position = position
		get_parent().add_child(kabloom)
	else:
		print("floof")

	set_state(State.GROUNDED)

func set_state(state: State):
	self.state = state

	match(state):
		State.GROUNDED:
			static_body.collision_layer = collision_layer_bits
			static_body.collision_mask = collision_mask_bits
			sprite.scale = original_sprite_scale
			z_index = 0
		State.GRABBED:
			static_body.collision_layer = 0b0
			static_body.collision_mask = 0b0
			sprite.scale = original_sprite_scale
		State.THROWN:
			static_body.collision_layer = 0b1000
			static_body.collision_mask = 0b1000
			z_index = 10
		State.SLIDING:
			static_body.collision_layer = collision_layer_bits
			static_body.collision_mask = collision_mask_bits
			sprite.scale = original_sprite_scale
			z_index = 5

func _ready():
	original_sprite_scale = sprite.scale

func _process(delta):
	if is_instance_valid(Main.player) and state == State.GROUNDED:
		if Main.player.position.y > position.y:
			z_index = -1
		else:
			z_index = 1

	match(state):
		State.THROWN:
			print("im bring thrown!")
			position += flight_velocity * delta
			flight_time_elapsed += delta

			if flight_time_elapsed >= total_flight_duration:
				sprite.scale = original_sprite_scale
				land(Impact.HARD)
			else:
				sprite.scale = original_sprite_scale * (1.0 + 0.5 * calc_throw_elevation())
		State.SLIDING:
			if sliding_bounds_rect.has_point(position - sliding_bounds_origin):
				pass
			else:
				land(Impact.SOFT)

func calc_throw_elevation():
	return -pow(2*clampf(flight_time_elapsed/total_flight_duration, 0.0, 1.0)-1,2)+1

func throw(flight_velocity: Vector2, total_flight_duration: float):
	self.flight_velocity = flight_velocity
	self.total_flight_duration = total_flight_duration
	flight_time_elapsed = 0.0
	set_state(State.THROWN)
