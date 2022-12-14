extends Line2D

const FILL_SPEED = 0.6
const OUTLINE_COLOUR = Color("#8ab060")
const OUTLINE_WIDTH = 4
const OFFLINE_COLOUR = Color("#4e584a")
const ONLINE_COLOUR = Color("#c2d368")
const FILL_WIDTH = 2

export (NodePath) var target
export (bool) var instant = false

var guide_points
var active = false
var next_idx = 0
var t = 0.0
var total_length = 0.0

func _ready():
	set_width(OUTLINE_WIDTH)
	set_default_color(OUTLINE_COLOUR)
	guide_points = get_points()
	create_offline_fill()
	calculate_total_length()

func calculate_total_length():
	var points = Array(get_points())
	while len(points) > 1:
		var previous_point = points.pop_front()
		total_length += previous_point.distance_to(points.front())

func activate():
	active = true
	create_online_fill()
	if instant and not target == null and has_node(target):
		get_node(target).activate()

func deactivate():
	active = false
	remove_online_fill()
	if instant and not target == null and has_node(target):
		get_node(target).deactivate()

func _process(delta):
	if active and not instant:
		var points = Array($OnlineFill.get_points())
		points.pop_back()
		t += (delta * total_length * FILL_SPEED) / guide_points[next_idx].distance_to(guide_points[next_idx-1])
		if 1.0 <= t:
			t -= 1
			points.append(guide_points[next_idx])
			next_idx += 1
		if next_idx < len(guide_points):
			points.append(points.back().linear_interpolate(guide_points[next_idx], t))
		else:
			active = false
			if target:
				get_node(target).activate()
		$OnlineFill.set_points(points)

func create_offline_fill():
	var line = Line2D.new()
	line.name = "OfflineFill"
#	line.set_position($Guide.get_position())
	line.set_points(guide_points)
	line.set_width(FILL_WIDTH)
	line.set_default_color(OFFLINE_COLOUR)
	add_child(line)

func create_online_fill():
	var line = Line2D.new()
	line.name = "OnlineFill"
#	line.set_position($Guide.get_position())
	if instant:
		line.set_points(guide_points)
	else:
		line.set_points([guide_points[0], guide_points[0]])
	line.set_width(FILL_WIDTH)
	line.set_default_color(ONLINE_COLOUR)
	line.set_modulate(Color(1.0, 1.5, 1.0))
	add_child(line)
	next_idx = 1

func remove_online_fill():
	var node = get_node("OnlineFill")
	remove_child(node)
	node.queue_free()
