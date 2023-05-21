extends Node2D

var object_registry: ObjectRegistry = ObjectRegistry.new()
var player: Player
var relic: GrabbableObject
var explode_relic: GrabbableObject
var split_relic: GrabbableObject
var split_relic_shard1: GrabbableObject
var split_relic_shard2: GrabbableObject
var boomerang_relic: GrabbableObject
var game_over: bool = false

var level_index: int = 0
var level_arr: Array = [
	load("res://Game/Views/Levels/1Room.tscn"),
	load("res://Game/Views/Levels/2Room.tscn"),
]

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

func reset_for_new_level():
	object_registry.reset()
	relic = null
	explode_relic = null
	split_relic = null
	split_relic_shard1 = null
	split_relic_shard2 = null
	boomerang_relic = null
