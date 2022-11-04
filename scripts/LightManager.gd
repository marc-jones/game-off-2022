extends Node2D

const light_ray = preload("res://nodes/LightRay.tscn")
const RAY_DENSITY = 3

func _ready():
	initiate_origins()

func add_ray(position, direction, origin_ray, origin_object):
	var ray = light_ray.instance()
	ray.set_position(position)
	ray.set_direction(direction)
	ray.connect("spawn_reflection", self, "add_ray")
	if not origin_ray == null:
		origin_ray.set_child_ray(ray)
		ray.set_parent_ray(origin_ray)
	if not origin_object == null:
		ray.add_exception(origin_object)
	add_child(ray)

func initiate_origins():
	for line in $Origins.get_children():
		var start = line.get_point_position(0)
		var end = line.get_point_position(1)
		var direction = (line.get_point_position(2) - end).normalized()
		var spread = start.distance_to(end)
		var spread_direction = (end - start).normalized()
		var number_of_rays = ceil(spread / RAY_DENSITY)
		for i in range(number_of_rays + 1):
			add_ray(
				start + i*(spread / number_of_rays)*spread_direction,
				direction,
				light_ray.instance(),
				null
			)
