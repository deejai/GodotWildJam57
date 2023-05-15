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
		elif is_instance_valid(held_object):
			held_object.set_state(GrabbableObject.State.GROUNDED)
			held_object.reparent(get_parent())
			held_object.position += direction * 100.0
			held_object = null

	var x_move = Input.get_axis("Move Left", "Move Right")
	var y_move = Input.get_axis("Move Up", "Move Down")

	if x_move != 0.0 or y_move != 0.0:
		if absf(x_move) > absf(y_move):
			direction = Vector2.LEFT if x_move < 0 else Vector2.RIGHT
		else:
			direction = Vector2.UP if y_move < 0 else Vector2.DOWN

		grab_ray.rotation = direction.angle()

	linear_velocity = Vector2(x_move, y_move) * 75.0

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
		held_object = null
	reset_throw_charge()

func _on_lag_fix_1_timeout():
	throw_charge_node.visible = false

func can_throw():
	if is_instance_valid(held_object) and held_object.is_throwable:
		return true
	else:
		return false
