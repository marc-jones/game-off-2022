extends Node2D

const TIME_CHANGE_FUDGE = 0.1

var total = 0.0
var active = false
var time_since_last_change = 0.0

export (NodePath) var target

onready var audio = get_tree().get_root().get_node("Audio")

func detect_light(delta):
	total = total + delta

func _process(delta):
	if time_since_last_change > TIME_CHANGE_FUDGE:
		if total == 0.0 and active:
			active = false
			$Bulb.hide()
			get_node(target).deactivate()
			audio.play_sound("off")
			time_since_last_change = 0.0
		elif total > 0.0 and not active:
			total = 0.0
			active = true
			$Bulb.show()
			get_node(target).activate()
			# Atrocious hack to stop the switch on the main screen making noise!
			if not get_parent().get_parent().get_name() == "MainMenu":
				audio.play_sound("on")
			time_since_last_change = 0.0
		else:
			total = 0.0
	else:
		time_since_last_change += delta
