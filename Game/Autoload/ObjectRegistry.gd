
var landingSurfaceRegistry: Dictionary = {}

func registerLandingSurface(obj: LandingSurface):
	landingSurfaceRegistry[obj.get_instance_id()] = obj

func unregisterLandingSurface(obj: LandingSurface):
	landingSurfaceRegistry.erase(obj.get_instance_id())

func reset():
	landingSurfaceRegistry = {}
