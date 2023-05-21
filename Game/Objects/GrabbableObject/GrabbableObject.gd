extends Node2D

class_name GrabbableObject

const collision_layer_bits = 0b1 | 0b100
const collision_mask_bits = 0b1

@export var is_throwable: bool = false
@export var is_breakable: bool = true
@export var is_relic: bool = false

enum RelicPower {NONE, TELEPORT, BOOMERANG, EXPLODE, SPLIT, SHARD}
@export var relic_power: RelicPower = RelicPower.NONE

@export var sprite: Sprite2D
var original_sprite_scale: Vector2

@export var static_body: StaticBody2D

enum State {GROUNDED, GRABBED, THROWN, SLIDING}
var state: State = State.GROUNDED

enum Impact {SOFT, HARD}

var velocity: Vector2 = Vector2.ZERO

var last_flight_duration: float = 0.0
var total_flight_duration: float = 0.0
var flight_time_elapsed: float = 0.0

var sliding_bounds_origin: Vector2
var sliding_bounds_rect: Rect2
var sliding_linger: float = 0.0

var hover_time: float = 0.0

func land(impact: Impact):
	var landing_surface: LandingSurface = Main.object_registry.get_landing_surface_at_point(position)

	if impact == Impact.HARD and is_breakable and (landing_surface == null or landing_surface.type not in [LandingSurface.Type.CUSHION, LandingSurface.Type.BOUNCER, LandingSurface.Type.SLIDER, LandingSurface.Type.PRESSURE_PLATE]):
		var p = AudioStreamPlayer.new()
		get_parent().add_child(p)
		p.volume_db = -6
		p.stream = load("res://Assets/SFX/Sounds-Tomb Randy - relic breaking.wav")
		p.play()
		queue_free()
		var kabloom = load("res://Game/Objects/Kablam.tscn").instantiate()
		kabloom.position = position
		if relic_power == RelicPower.EXPLODE:
			kabloom.scale = Vector2(2,2)
			var blast_radius: Area2D = get_node("BlastRadius")
			for obj in blast_radius.get_overlapping_bodies():
				if obj.get_parent() is ExplodableWall:
					var wall_obj: ExplodableWall = obj.get_parent()
					var obj_kabloom = load("res://Game/Objects/Kablam.tscn").instantiate()
					obj_kabloom.position = wall_obj.position
					get_parent().add_child(obj_kabloom)
					wall_obj.queue_free()
		get_parent().add_child(kabloom)
		if is_relic and relic_power not in [RelicPower.EXPLODE]:
			for offset_mult in [-1, 0, 1]:
				var snake = load("res://Game/Objects/DemonSnake.tscn").instantiate()
				snake.position = position + Vector2.RIGHT * offset_mult * 50.0
				snake.rotation = randf() * 2 * PI
				get_parent().add_child(snake)
	elif landing_surface and landing_surface.type in [LandingSurface.Type.CUSHION, LandingSurface.Type.PRESSURE_PLATE]:
		last_flight_duration = 0.0
		print("floof")
		position = landing_surface.position
		set_state(State.GROUNDED)
		if landing_surface.type == LandingSurface.Type.PRESSURE_PLATE:
			Main.destroy_pressure_plate_walls()
	elif landing_surface and landing_surface.type == LandingSurface.Type.BOUNCER:
		print("boing!")
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.volume_db = -6
		p.stream = load("res://Assets/SFX/Sounds-Tomb Randy - boing.mp3")
		p.play()
		var bounce_velocity: Vector2 = 75.0 * (velocity.normalized() if velocity != Vector2.ZERO else Vector2.RIGHT)
		if bounce_velocity.length_squared() < velocity.length_squared():
			bounce_velocity = velocity

		throw(bounce_velocity, max(1.0, last_flight_duration))
	elif landing_surface and landing_surface.type == LandingSurface.Type.SLIDER:
		last_flight_duration = 0.0
		print("schweeee!")
		sliding_bounds_origin = landing_surface.position
		sliding_bounds_rect = landing_surface.area_rect
		sliding_linger = 0.15
		set_state(State.SLIDING)
	else:
		print("plop.")
		set_state(State.GROUNDED)

func set_state(state: State):
	self.state = state

	match(state):
		State.GROUNDED:
			static_body.collision_layer = collision_layer_bits
			static_body.collision_mask = collision_mask_bits
			sprite.scale = original_sprite_scale
			velocity = Vector2.ZERO
			z_index = 0
		State.GRABBED:
			static_body.collision_layer = 0b0
			static_body.collision_mask = 0b0
			sprite.scale = original_sprite_scale
			velocity = Vector2.ZERO
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
	if is_relic:
		match(relic_power):
			RelicPower.TELEPORT:
				Main.relic = self
			RelicPower.SPLIT:
				Main.split_relic = self
			RelicPower.EXPLODE:
				Main.explode_relic = self
			RelicPower.BOOMERANG:
				Main.boomerang_relic = self
			RelicPower.SHARD:
				if is_instance_valid(Main.split_relic_shard1):
					Main.split_relic_shard2 = self
				else:
					Main.split_relic_shard1 = self
			_:
				printerr("Invalid relic power")
				assert(false)

func _process(delta):
	if is_instance_valid(Main.player) and state == State.GROUNDED:
		if Main.player.position.y > position.y:
			z_index = -1
		else:
			z_index = 1

	match(state):
		State.THROWN:
			print("im bring thrown!")
			position += velocity * delta

			hover_time = max(0.0, hover_time - delta)
			if hover_time <= 0.0:
				flight_time_elapsed += delta

			if flight_time_elapsed >= total_flight_duration:
				sprite.scale = original_sprite_scale
				land(Impact.HARD)
			else:
				sprite.scale = original_sprite_scale * (1.0 + 0.5 * calc_throw_elevation())
		State.SLIDING:
			if sliding_bounds_rect.has_point(position - sliding_bounds_origin):
				# keep sliding
				position += velocity * delta
			else:
				sliding_linger = max(0.0, sliding_linger - delta)
				if sliding_linger > 0.0:
					position += velocity * delta
				else:
					land(Impact.SOFT)

func calc_throw_elevation():
	return -pow(2*clampf(flight_time_elapsed/total_flight_duration, 0.0, 1.0)-1,2)+1

func throw(velocity: Vector2, total_flight_duration: float):
	self.velocity = velocity
	self.total_flight_duration = total_flight_duration
	self.last_flight_duration = total_flight_duration
	flight_time_elapsed = 0.0
	set_state(State.THROWN)
