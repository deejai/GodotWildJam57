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
var game_over_timer: float = 5.0

var level_index: int = 0
var level_arr: Array = [
	load("res://Game/Views/Levels/1Room.tscn"),
	load("res://Game/Views/Levels/2Room.tscn"),
	load("res://Game/Views/Levels/3Room.tscn"),
	load("res://Game/Views/Levels/4Room.tscn"),
	load("res://Game/Views/Levels/5Room.tscn"),
	load("res://Game/Views/Levels/6Room.tscn"),
	load("res://Game/Views/Levels/7Room.tscn"),
	load("res://Game/Views/Levels/8Room.tscn"),
	load("res://Game/Views/Levels/9Room.tscn"),
]

func _ready():
	pass # Replace with function body.

func _process(delta):
	Main.toggle_fullscreen()

	if not game_over and not is_instance_valid(player):
		game_over_timer -= delta
		if game_over_timer <= 0.0:
			load_current_level()

static func toggle_fullscreen():
	if Input.is_action_just_pressed("Toggle Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_ground_water(is_active: bool):
	for obj in object_registry.landing_surface_registry.values():
		if is_instance_valid(obj) and obj.type == LandingSurface.Type.WATER:
			obj.set_active(is_active)

func reset_level_params():
	object_registry.reset()
	relic = null
	explode_relic = null
	split_relic = null
	split_relic_shard1 = null
	split_relic_shard2 = null
	boomerang_relic = null
	game_over_timer = 5.0

func load_current_level():
	reset_level_params()
	get_tree().change_scene_to_packed(level_arr[level_index])

func go_to_next_level():
	level_index += 1
	load_current_level()
