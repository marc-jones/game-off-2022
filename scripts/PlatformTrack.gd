tool
extends Line2D

const PLATFORM_SPEED = 60.0
const OUTLINE_COLOUR = Color("#8ab060")
const OUTLINE_WIDTH = 4
const OFFLINE_COLOUR = Color("#4e584a")
const ONLINE_COLOUR = Color("#c2d368")
const FILL_WIDTH = 2
const OFFLINE_NODE_TEX = preload("res://assets/platform/offline_node.png")
const ONLINE_NODE_TEX = preload("res://assets/light_switch/bulb.png")

export (int) var start_node setget set_start_node
export (int) var end_node
export (NodePath) var platform_path

var guide_points
var active = false
var next_idx = 1
var t = 0.0
var direction = 1
var online_nodes = []

func _ready():
	set_width(OUTLINE_WIDTH)
	set_default_color(OUTLINE_COLOUR)
	guide_points = get_points()
	create_offline_fill()
	create_nodes()
	create_online_fill()
	move_platform_to_start()

func move_platform_to_start():
	if (
		not start_node == null and
		not platform_path == null and
		len(guide_points) > 0
	):
		get_node(platform_path).set_position(guide_points[start_node])

func activate():
	active = true
	$OnlineFill.show()
	for node in online_nodes:
		node.show()

func deactivate():
	active = false
	$OnlineFill.hide()
	for node in online_nodes:
		node.hide()

func _physics_process(delta):
	if not Engine.editor_hint:
		if active:
			var platform = get_node(platform_path)
			t += (delta * PLATFORM_SPEED) / guide_points[next_idx].distance_to(guide_points[next_idx-direction])
			if 1.0 <= t:
				t -= 1.0
				next_idx += direction
			clamp_next_idx()
			var next_pos = guide_points[next_idx-direction].linear_interpolate(
				guide_points[next_idx],
				t
			)
			test_change_direction_due_to_collision(platform, next_pos)
			next_pos = guide_points[next_idx-direction].linear_interpolate(
				guide_points[next_idx],
				t
			)
			platform.position = next_pos

func test_change_direction_due_to_collision(platform, next_pos):
	var collision = platform.move_and_collide(next_pos - platform.position, true, true, true)
	if collision:
		if collision.collider.is_in_group("platform_blocker"):
			var push_collision = collision.collider.move_and_collide(next_pos - platform.position, true, true, true)
			if not push_collision == null:
				next_idx -= direction
				direction *= -1
				clamp_next_idx()
				t = (
					guide_points[next_idx-direction].distance_to(platform.position) /
					guide_points[next_idx].distance_to(guide_points[next_idx-direction])
				)

func clamp_next_idx():
	if next_idx < 0:
		direction *= -1
		next_idx = 1
	if next_idx == len(points):
		direction *= -1
		next_idx = len(points) - 2

func create_offline_fill():
	var line = Line2D.new()
	line.name = "OfflineFill"
	line.set_points(guide_points)
	line.set_width(FILL_WIDTH)
	line.set_default_color(OFFLINE_COLOUR)
	add_child(line)

func create_online_fill():
	var line = Line2D.new()
	line.name = "OnlineFill"
	line.set_points(guide_points)
	line.set_width(FILL_WIDTH)
	line.set_default_color(ONLINE_COLOUR)
	line.set_modulate(Color(1.0, 1.5, 1.0))
	line.hide()
	add_child(line)

func set_start_node(input_start_node):
	start_node = input_start_node
	move_platform_to_start()

func create_nodes():
	for pos in guide_points:
		add_node(pos)

func add_node(input_pos):
	var offline_node = Sprite.new()
	offline_node.name = "OfflineNode"
	offline_node.texture = OFFLINE_NODE_TEX
	offline_node.position = input_pos
	add_child(offline_node)
	var online_node = Sprite.new()
	online_node.name = "OnlineNode"
	online_node.texture = ONLINE_NODE_TEX
	online_node.position = input_pos
	online_node.hide()
	online_nodes.append(online_node)
	add_child(online_node)
