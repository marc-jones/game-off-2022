extends Node2D

signal start_menu


func _ready():
	var _discard = $UI/Back.connect("button_up", self, "start_menu")

func start_menu():
	emit_signal("start_menu")
