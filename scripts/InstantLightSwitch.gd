extends Node2D

var total = 0.0
var active = false

export (NodePath) var target

func detect_light(delta):
	total = total + delta

func _process(delta):
	if total == 0.0 and active:
		active = false
		$Bulb.hide()
		get_node(target).deactivate()
	elif total > 0.0 and not active:
		total = 0.0
		active = true
		$Bulb.show()
		get_node(target).activate()
	else:
		total = 0.0
