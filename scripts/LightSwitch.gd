extends Node2D

const FILL_SPEED = 50.0
const FILL_DECAY = 20.0

var total = 0.0
var previous_total = 0.0
var active = false

func _ready():
	pass # Replace with function body.

func detect_light(delta):
	total = clamp(total + delta, 0.0, FILL_SPEED)
	update_fill()

func update_fill():
	$Fill.get_material().set_shader_param("t", total / FILL_SPEED)
	if not active and total == FILL_SPEED:
		active = true
		$Bulb.show()

func _process(delta):
	if total == previous_total:
		if total < FILL_SPEED:
			total = clamp(total - delta * FILL_DECAY, 0.0, FILL_SPEED)
			update_fill()
	previous_total = total
