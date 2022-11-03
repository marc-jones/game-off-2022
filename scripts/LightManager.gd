extends Node2D

const light_ray = preload("res://nodes/LightRay.tscn")

func _ready():
	add_ray(Vector2(0, 0), Vector2(50, 50), light_ray.instance(), null)

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
