extends Node2D

const menu_scene = preload("res://nodes/scenes/MainMenu.tscn")
const level_select_scene = preload("res://nodes/scenes/LevelSelect.tscn")
const credits_scene = preload("res://nodes/scenes/Credits.tscn")
const scene_transition = preload("res://nodes/scenes/SceneTransition.tscn")

const CONFIG_FILEPATH = "user://game_off_2022.cfg"
const LEVELS = [
	preload("res://nodes/levels/LevelX.tscn"),
	preload("res://nodes/PlayState.tscn")
]
var levels_completed = []
var current_level = 0

func _ready():
	load_config()
	deferred_start_menu()

func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILEPATH)
	if err == OK:
		levels_completed = config.get_value("save", "levels_completed", levels_completed)
	save_config()

func save_config():
	var config = ConfigFile.new()
	config.set_value("save", "levels_completed", levels_completed)
	config.save(CONFIG_FILEPATH)

func level_complete(idx):
	levels_completed.append(idx)
	levels_completed.sort()
	save_config()
	if idx + 1 < len(LEVELS):
		start_level(idx + 1)
	else:
		start_menu()

# PlayState
#func start_new_game():
#	if not has_node("scene_transition"):
#		initiate_fade_to_black("deferred_new_game")
#
#func deferred_new_game():
#	clear_scene()
#	var new_game = play_scene.instance()
#	new_game.connect("quit", self, "start_menu")
#	new_game.connect("restart", self, "start_new_game")
#	add_child(new_game)
#	initiate_fade_to_transparent("remove_transition_overlay")

# Start specific level
func start_level(idx):
	if not has_node("SceneTransition"):
		current_level = idx
		initiate_fade_to_black("deferred_start_level", get_global_mouse_position())

func deferred_start_level():
	clear_scene()
	var level = LEVELS[current_level].instance()
	level.level_idx = current_level
#	menu.connect("start_game", self, "start_new_game")
#	menu.connect("start_level_select", self, "start_level_select")
	level.connect("level_complete", self, "level_complete")
	add_child(level)
	initiate_fade_to_transparent("remove_transition_overlay", get_global_mouse_position())

# MainMenu
func start_menu():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_menu", get_global_mouse_position())

func deferred_start_menu():
	clear_scene()
	var menu = menu_scene.instance()
#	menu.connect("start_game", self, "start_new_game")
	menu.connect("start_level_select", self, "start_level_select")
	menu.connect("start_credits", self, "start_credits")
	add_child(menu)
	initiate_fade_to_transparent("remove_transition_overlay", get_global_mouse_position())

# CreditsState
func start_credits():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_credits", get_global_mouse_position())

func deferred_start_credits():
	clear_scene()
	var credits = credits_scene.instance()
	credits.connect("start_menu", self, "start_menu")
	add_child(credits)
	initiate_fade_to_transparent("remove_transition_overlay", get_global_mouse_position())

# LevelSelect
func start_level_select():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_level_select", get_global_mouse_position())

func deferred_start_level_select():
	clear_scene()
	var level_select = level_select_scene.instance()
	level_select.connect("start_menu", self, "start_menu")
	level_select.connect("start_level", self, "start_level")
	level_select.number_of_levels = len(LEVELS)
	level_select.levels_completed = levels_completed
	add_child(level_select)
	initiate_fade_to_transparent("remove_transition_overlay", get_global_mouse_position())

# Transition functions
func clear_scene():
	for child in get_children():
		child.free()

func initiate_fade_to_black(input_callback_str, focus_point):
	var transition = scene_transition.instance()
	transition.set_to_transparent()
	transition.connect("transition_finished", self, "transition_finished_callback")
	add_child(transition)
	transition.fade_to_black(input_callback_str, focus_point)

func initiate_fade_to_transparent(input_callback_str, focus_point):
	var transition = scene_transition.instance()
	transition.set_to_black()
	transition.connect("transition_finished", self, "transition_finished_callback")
	add_child(transition)
	transition.fade_to_transparent(input_callback_str, focus_point)

func transition_finished_callback(callback_str):
	call_deferred(callback_str)

func remove_transition_overlay():
	$SceneTransition.queue_free()
