extends Node2D

signal level_complete

var level_idx = 0

func _ready():
	setup_exit()

func setup_exit():
	$LevelExit.connect("body_entered", self, "body_entered_callback")

func body_entered_callback(body):
	if body == $Player:
		emit_signal("level_complete", level_idx)
