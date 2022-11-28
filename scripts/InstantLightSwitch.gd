extends Node2D

var total = 0.0
var active = false

export (NodePath) var target

onready var audio = get_tree().get_root().get_node("Audio")

func detect_light(delta):
	total = total + delta

func _process(delta):
	if total == 0.0 and active:
		active = false
		$Bulb.hide()
		get_node(target).deactivate()
		audio.play_sound("off")
	elif total > 0.0 and not active:
		total = 0.0
		active = true
		$Bulb.show()
		get_node(target).activate()
		audio.play_sound("on")
	else:
		total = 0.0
