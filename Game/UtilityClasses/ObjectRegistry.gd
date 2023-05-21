
class_name ObjectRegistry

var landing_surface_registry: Dictionary = {}

func get_landing_surface_at_point(position: Vector2):
	var surface = null
	var highest_priority = -1

	for key in landing_surface_registry.keys():
		var obj: LandingSurface = landing_surface_registry[key]
		if not is_instance_valid(obj):
			landing_surface_registry.erase(key)
			continue

		if not obj.active:
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
	landing_surface_registry[obj.get_instance_id()] = obj

func unregister_landing_surface(obj: LandingSurface):
	landing_surface_registry.erase(obj.get_instance_id())

func reset():
	landing_surface_registry = {}
