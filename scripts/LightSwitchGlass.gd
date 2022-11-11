extends Area2D

const light_detector = true

func _ready():
	pass # Replace with function body.

func detect_light(delta):
	get_parent().detect_light(delta)
