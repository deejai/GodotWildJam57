extends Node2D

var object_registry: ObjectRegistry = ObjectRegistry.new()
var player: Player
var relic: GrabbableObject

func _ready():
	pass # Replace with function body.

func _process(delta):
	Main.toggle_fullscreen()

static func toggle_fullscreen():
	if Input.is_action_just_pressed("Toggle Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_ground_water(active: bool):
	for obj in object_registry.landing_surface_registry.values():
		if is_instance_valid(obj) and obj.type == LandingSurface.Type.WATER:
			obj.active = active
			obj.visible = active
