extends Node2D

signal start_menu
signal start_level
signal start_level_select
signal level_complete

const pause_screen = preload("res://nodes/scenes/PauseMenu.tscn")

var level_idx = 0
var paused = false

func _ready():
	setup_exit()

func setup_exit():
	$LevelExit.connect("body_entered", self, "body_entered_callback")

func body_entered_callback(body):
	if body == $Player:
		emit_signal("level_complete", level_idx)

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if paused:
		pause_mode = PAUSE_MODE_INHERIT
		for child in get_children():
			child.pause_mode = PAUSE_MODE_INHERIT
		var pause = get_node("PauseMenu")
		remove_child(pause)
		pause.queue_free()
		get_tree().paused = false
	else:
		pause_mode = PAUSE_MODE_PROCESS
		for child in get_children():
			child.pause_mode = PAUSE_MODE_STOP
		var pause = pause_screen.instance()
		pause.get_node("Restart").connect("button_up", self, "emit_signal", ["start_level", level_idx])
		pause.get_node("SelectLevel").connect("button_up", self, "emit_signal", ["start_level_select"])
		pause.get_node("Quit").connect("button_up", self, "emit_signal", ["start_menu"])
		add_child(pause)
		get_tree().paused = true
	paused = not paused
