extends Node2D

signal start_menu

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	var _discard = $UI/Back.connect("button_up", self, "start_menu")

func start_menu():
	audio.play_sound("on")
	emit_signal("start_menu")
