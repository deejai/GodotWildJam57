extends Node2D

class_name GrabbableObject

const collision_layer_bits = 0b1 | 0b100
const collision_mask_bits = 0b1

@export var is_throwable: bool = false

@export var sprite: Sprite2D
var original_sprite_scale: Vector2

@export var static_body: StaticBody2D

enum State {GROUNDED, GRABBED, THROWN}
var state: State = State.GROUNDED

var flight_velocity: Vector2 = Vector2.ZERO
var total_flight_duration: float = 0.0
var flight_time_elapsed: float = 0.0

var payload: Callable = func(): print("BLAM!")

func set_state(state: State):
	self.state = state

	match(state):
		State.GROUNDED:
			static_body.collision_layer = collision_layer_bits
			static_body.collision_mask = collision_mask_bits
			z_index = 0
		State.GRABBED:
			static_body.collision_layer = 0b0
			static_body.collision_mask = 0b0
			sprite.scale = original_sprite_scale
		State.THROWN:
			static_body.collision_layer = 0b1000
			static_body.collision_mask = 0b1000
			z_index = 20

func _ready():
	original_sprite_scale = sprite.scale

func _process(delta):
	if state == State.THROWN:
		print("im bring thrown!")
		position += flight_velocity * delta
		flight_time_elapsed += delta

		if flight_time_elapsed >= total_flight_duration:
			sprite.scale = original_sprite_scale
			set_state(State.GROUNDED)
			payload.call()
		else:
			sprite.scale = original_sprite_scale * (1.0 + 0.5 * calc_throw_elevation())

func calc_throw_elevation():
	return -pow(2*clampf(flight_time_elapsed/total_flight_duration, 0.0, 1.0)-1,2)+1

func throw(flight_velocity: Vector2, total_flight_duration: float):
	self.flight_velocity = flight_velocity
	self.total_flight_duration = total_flight_duration
	flight_time_elapsed = 0.0
	set_state(State.THROWN)
