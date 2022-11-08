extends Node2D

const light_ray = preload("res://nodes/LightRay.tscn")
const RAY_DENSITY = 1
const RAY_GROUPING_MAX_DIFFERENCE = 0.01
const MAX_ALPHA = 0.8

var origin_groups = []

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
	ray.force_raycast_update()
	return(ray)

func initiate_origins():
	origin_groups = []
	for line in $Origins.get_children():
		var origin_rays = []
		var start = line.get_point_position(0) + line.get_position()
		var end = line.get_point_position(1) + line.get_position()
		var direction = (
			line.get_point_position(2) + line.get_position() - end
		).normalized()
		var spread = start.distance_to(end)
		var spread_direction = (end - start).normalized()
		var number_of_rays = ceil(spread / RAY_DENSITY)
		for i in range(number_of_rays + 1):
			var ray = add_ray(
				start + i*(spread / number_of_rays)*spread_direction,
				direction,
				light_ray.instance(),
				null
			)
			origin_rays.append(ray)
		origin_groups.append(origin_rays)
		line.hide()

func _draw():
	for ray_group in ray_groupings():
		if len(ray_group) > 1:
			var positions = PoolVector2Array()
			var cast_tos = PoolVector2Array()
			for ray in ray_group:
				positions.append(ray.get_position())
				if ray.is_colliding():
					cast_tos.append(ray.get_collision_point())
				else:
					cast_tos.append(ray.get_position() + ray.get_cast_to())
			# Calculate alpha
			var alpha = calculate_alpha(
				positions[0].distance_to(positions[-1]),
				len(ray_group)
			)
			# Complete polygon
			cast_tos.invert()
			positions.append_array(cast_tos)
			var simplified_polygons = Geometry.merge_polygons_2d(positions, PoolVector2Array([]))
			var draw_polygon_var = null
			var current_max_verticies = 0
			for polygon in simplified_polygons:
				if len(polygon) > current_max_verticies:
					draw_polygon_var = polygon
					current_max_verticies = len(polygon)
			if not (
				draw_polygon_var == null or
				Geometry.triangulate_polygon(draw_polygon_var).empty()
			):
				draw_polygon(draw_polygon_var, [Color(1, 1, 0.6, alpha)])

func calculate_alpha(distance, ray_count):
	if distance == 0 or ray_count == 0:
		return(0.0)
	return(
		min(1.0, RAY_DENSITY / (distance / ray_count)) * MAX_ALPHA
	)

func _physics_process(delta):
	update()

func ray_groupings():
	var return_groupings = []
	var ray_hierarchy = []
	for origin_rays in origin_groups:
		# Add the origins as a group
		return_groupings.append(origin_rays)
		# Establish child groups
		var child_group = []
		for ray in origin_rays:
			if is_instance_valid(ray.child_ray):
				child_group.append(ray.child_ray)
		ray_hierarchy.append(child_group)
	while len(ray_hierarchy) > 0:
		var ray_group = ray_hierarchy.pop_front()
		var child_group = []
		var current_group = []
		for ray in ray_group:
			if is_instance_valid(ray.child_ray):
				child_group.append(ray.child_ray)
			if len(current_group) == 0:
				current_group.append(ray)
			else:
				var angle = ray.get_cast_to().angle_to(current_group.back().get_cast_to())
				if abs(angle) <= RAY_GROUPING_MAX_DIFFERENCE:
					current_group.append(ray)
				else:
					return_groupings.append(current_group)
					current_group = [ray]
		if len(current_group) > 0:
			return_groupings.append(current_group)
		if len(child_group) > 0:
			ray_hierarchy.append(child_group)
	return(return_groupings)
