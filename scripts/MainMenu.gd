extends Node2D

signal start_game
signal start_level_select
signal start_credits

func _ready():
	var _discard = $UI/Play.connect("button_up", self, "start_game")
	_discard = $UI/LevelSelect.connect("button_up", self, "start_level_select")
	_discard = $UI/Credits.connect("button_up", self, "start_credits")

func start_game():
	emit_signal("start_game")

func start_level_select():
	emit_signal("start_level_select")

func start_credits():
	emit_signal("start_credits")
