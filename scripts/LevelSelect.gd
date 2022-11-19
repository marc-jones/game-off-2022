extends Node2D

signal start_level
signal start_menu

var number_of_levels = 18
var levels_completed = [0, 1, 2, 3, 8]

const BUTTON_START_POS = Vector2(240, 204)
const BUTTON_SPACING = 96
const ROW_LENGTH = 6

onready var PACKED_LEVEL_BUTTON = preload("res://nodes/LevelSelectButton.tscn")
onready var PACKED_TICK = preload("res://nodes/Tick.tscn")

func _ready():
	var _discard = $UI/Back.connect("button_up", self, "start_menu")
	setup_level_buttons()

func start_menu():
	emit_signal("start_menu")

func setup_level_buttons():
	for idx in range(number_of_levels):
		var button = PACKED_LEVEL_BUTTON.instance()
		var _discard = button.connect("button_up", self, "start_level", [idx])
		button.text = str(idx + 1)
		button.rect_position = (
			BUTTON_START_POS +
			Vector2(
				BUTTON_SPACING * (idx % ROW_LENGTH),
				BUTTON_SPACING * floor(idx / ROW_LENGTH)
			)
		)
		$UI.add_child(button)
		if idx in levels_completed:
			var tick = PACKED_TICK.instance()
			tick.position = button.rect_position
			$UI.add_child(tick)
