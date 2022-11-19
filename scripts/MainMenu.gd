extends Node2D

signal play
signal start_level_select
signal start_credits

func _ready():
	var _discard = $UI/Play.connect("button_up", self, "play")
	_discard = $UI/LevelSelect.connect("button_up", self, "start_level_select")
	_discard = $UI/Credits.connect("button_up", self, "start_credits")

func play():
	emit_signal("play")

func start_level_select():
	emit_signal("start_level_select")

func start_credits():
	emit_signal("start_credits")
