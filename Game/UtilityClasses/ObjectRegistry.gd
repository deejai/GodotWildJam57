
class_name ObjectRegistry

var landingSurfaceRegistry: Dictionary = {}

func get_landing_surface_at_point(position: Vector2):
	var surface = null
	var highest_priority = -1

	for key in landingSurfaceRegistry.keys():
		var obj: LandingSurface = landingSurfaceRegistry[key]
		if not is_instance_valid(obj):
			landingSurfaceRegistry.erase(key)
			continue

		if obj.has_point(position):
			if surface == null or obj.priority > highest_priority:
				surface = obj
				highest_priority = obj.priority
		else:
			print("thrown, surface, rect")
			print(position)
			print(obj.position)
			print(obj.area_rect)

	return surface

func register_landing_surface(obj: LandingSurface):
	landingSurfaceRegistry[obj.get_instance_id()] = obj

func unregister_landing_surface(obj: LandingSurface):
	landingSurfaceRegistry.erase(obj.get_instance_id())

func reset():
	landingSurfaceRegistry = {}
