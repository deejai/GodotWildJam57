extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_charge_node: Node2D = $ThrowChargeNode
@onready var throw_charge_material: Material = $ThrowChargeNode/Foreground.material

@onready var grab_ray: RayCast2D = $GrabRay

@onready var hud: PlayerHUD = $HUD

var charging_throw: bool = false
const THROW_CHARGE_TIME: float = 2.0
var throw_charge: float = 0.0

var held_object: GrabbableObject = null

var direction: Vector2 = Vector2.DOWN

func _ready():
	sprite.play()

func _process(delta):
	if charging_throw:
		if Input.is_action_pressed("Cancel Throw"):
			reset_throw_charge()
		elif Input.is_action_pressed("Charge Throw"):
			throw_charge = min(1.0, throw_charge + delta / THROW_CHARGE_TIME)
			throw_charge_material.set_shader_parameter("throw_charge", (1.0/3.334)*log(throw_charge+.035)+0.99)
		else:
			throw()
	else:
		if can_throw() and Input.is_action_just_pressed("Charge Throw"):
			start_charging_throw()

	if Input.is_action_just_pressed("Grab"):
		if not is_instance_valid(held_object) and grab_ray.is_colliding():
			var obj = grab_ray.get_collider().get_parent()
			if obj is GrabbableObject:
				obj.set_state(GrabbableObject.State.GRABBED)
				held_object = obj
				held_object.reparent(self)
				held_object.position = Vector2.ZERO
				update_held_object_visuals()
		elif is_instance_valid(held_object):
			held_object.set_state(GrabbableObject.State.GROUNDED)
			held_object.reparent(get_parent())
			held_object.position += direction * (25.0 if direction.x != 0.0 else 50.0)
			held_object.z_index = 10
			held_object = null

	var move_vec = Vector2(Input.get_axis("Move Left", "Move Right"), Input.get_axis("Move Up", "Move Down")).normalized()

	if move_vec.x != 0.0 or move_vec.y != 0.0:
		if absf(move_vec.x) > absf(move_vec.y):
			if move_vec.x < 0:
				direction = Vector2.LEFT
				if is_instance_valid(held_object):
					sprite.animation = "walk_left_holding"
					update_held_object_visuals()
				else:
					sprite.animation = "walk_left"
			else:
				direction = Vector2.RIGHT
				if is_instance_valid(held_object):
					sprite.animation = "walk_right_holding"
					update_held_object_visuals()
				else:
					sprite.animation = "walk_right"
		else:
			if move_vec.y < 0:
				direction = Vector2.UP
				if is_instance_valid(held_object):
					sprite.animation = "walk_up_holding"
					update_held_object_visuals()
				else:
					sprite.animation = "walk_up"
			else:
				direction = Vector2.DOWN
				if is_instance_valid(held_object):
					sprite.animation = "walk_down_holding"
					update_held_object_visuals()
				else:
					sprite.animation = "walk_down"

		grab_ray.rotation = direction.angle()
	else:
		match direction:
			Vector2.LEFT:
				sprite.animation = "idle_left" + ("_holding" if is_instance_valid(held_object) else "")
			Vector2.RIGHT:
				sprite.animation = "idle_right" + ("_holding" if is_instance_valid(held_object) else "")
			Vector2.UP:
				sprite.animation = "idle_up" + ("_holding" if is_instance_valid(held_object) else "")
			Vector2.DOWN:
				sprite.animation = "idle_down" + ("_holding" if is_instance_valid(held_object) else "")

	linear_velocity = move_vec * 75.0

func reset_throw_charge():
	charging_throw = false
	throw_charge = 0.0
	throw_charge_node.visible = false

func start_charging_throw():
	throw_charge_node.rotation = throw_charge_node.global_position.angle_to_point(get_global_mouse_position())
	charging_throw = true
	throw_charge = 0.0
	throw_charge_node.visible = true

func throw():
	if is_instance_valid(held_object):
		held_object.throw(Vector2.RIGHT.rotated(throw_charge_node.rotation) * throw_charge * 200.0, 2.0)
		held_object.reparent(get_parent())
		held_object.z_index = 20
		held_object = null
	reset_throw_charge()

func _on_lag_fix_1_timeout():
	throw_charge_node.visible = false

func update_held_object_visuals():
	match(direction):
		Vector2.LEFT:
			held_object.position = Vector2(-15.0, 0.0)
			held_object.z_index = -10

		Vector2.RIGHT:
			held_object.position = Vector2(15.0, 0.0)
			held_object.z_index = -10

		Vector2.UP:
			held_object.position = Vector2.ZERO
			held_object.z_index = -10

		Vector2.DOWN:
			held_object.position = Vector2.ZERO
			held_object.z_index = 20

func can_throw():
	if is_instance_valid(held_object) and held_object.is_throwable:
		return true
	else:
		return false
