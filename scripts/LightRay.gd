extends RayCast2D

signal spawn_reflection

const max_length = 2048

var child_ray
var parent_ray

func _ready():
	pass

func set_direction(input_vec: Vector2):
	set_cast_to(input_vec.normalized() * max_length)

func _physics_process(delta):
	# Parent ray check is a bit of a hack to get around the issue of child rays
	# not reliably being killed
	if is_instance_valid(parent_ray):
		if is_colliding():
			if is_instance_valid(child_ray):
				# Update child
				child_ray.set_position(get_collision_point())
				child_ray.set_direction(get_collision_normal())
				child_ray.force_raycast_update()
			else:
				# Create child
				emit_signal(
					"spawn_reflection",
					get_collision_point(),
					get_collision_normal(),
					self,
					get_collider()
				)
		else:
			if is_instance_valid(child_ray):
				child_ray.kill()
	else:
		kill()

func set_child_ray(input_ray):
	child_ray = input_ray

func set_parent_ray(input_ray):
	parent_ray = input_ray

func kill():
	if is_instance_valid(child_ray): 
		child_ray.kill()
	queue_free()
