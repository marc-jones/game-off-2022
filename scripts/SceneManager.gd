extends Node2D

const menu_scene = preload("res://nodes/scenes/MainMenu.tscn")
const level_select_scene = preload("res://nodes/scenes/LevelSelect.tscn")
const credits_scene = preload("res://nodes/scenes/Credits.tscn")
const win_scene = preload("res://nodes/scenes/Win.tscn")
const scene_transition = preload("res://nodes/scenes/SceneTransition.tscn")

const CONFIG_FILEPATH = "user://game_off_2022.cfg"
const LEVELS = [
	preload("res://nodes/levels/Level1.tscn"),
	preload("res://nodes/levels/Level2.tscn"),
	preload("res://nodes/levels/Level3.tscn"),
	preload("res://nodes/levels/Level4.tscn"),
	preload("res://nodes/levels/Level5.tscn"),
	preload("res://nodes/levels/Level6.tscn"),
	preload("res://nodes/levels/LevelC.tscn"),
	preload("res://nodes/levels/LevelX.tscn"),
	preload("res://nodes/levels/LevelA.tscn"),
	preload("res://nodes/levels/LevelD.tscn"),
	preload("res://nodes/levels/LevelB.tscn"),
	preload("res://nodes/levels/LevelE.tscn")
]
var levels_completed = []
var current_level = 0
var global_focus_pos = null

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
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

func level_complete(idx, player_position):
	if not idx in levels_completed:
		levels_completed.append(idx)
	levels_completed.sort()
	save_config()
	global_focus_pos = player_position
	if idx + 1 < len(LEVELS):
		start_level(idx + 1)
	else:
		var completed = true
		for idx in range(len(LEVELS)):
			if not idx in levels_completed:
				completed = false
		if completed:
			start_win_screen()
		else:
			start_level_select()
	global_focus_pos = player_position

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

func get_valid_position():
	if global_focus_pos == null:
		return(get_global_mouse_position())
	var return_val = global_focus_pos
	global_focus_pos = null
	return(return_val)

# Start first level
func play():
	for idx in range(len(LEVELS)):
		if not idx in levels_completed:
			start_level(idx)
			return
	start_level(0)

# Start specific level
func start_level(idx):
	if not has_node("SceneTransition"):
		current_level = idx
		initiate_fade_to_black("deferred_start_level", get_valid_position())

func deferred_start_level():
	clear_scene()
	var level = LEVELS[current_level].instance()
	level.level_idx = current_level
	level.connect("start_level", self, "start_level")
	level.connect("start_menu", self, "start_menu")
	level.connect("start_level_select", self, "start_level_select")
	level.connect("level_complete", self, "level_complete")
	add_child(level)
	initiate_fade_to_transparent("remove_transition_overlay", get_valid_position())

# MainMenu
func start_menu():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_menu", get_valid_position())

func deferred_start_menu():
	clear_scene()
	var menu = menu_scene.instance()
	menu.connect("play", self, "play")
	menu.connect("start_level_select", self, "start_level_select")
	menu.connect("start_credits", self, "start_credits")
	add_child(menu)
	initiate_fade_to_transparent("remove_transition_overlay", get_valid_position())

# CreditsState
func start_credits():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_credits", get_valid_position())

func deferred_start_credits():
	clear_scene()
	var credits = credits_scene.instance()
	credits.connect("start_menu", self, "start_menu")
	add_child(credits)
	initiate_fade_to_transparent("remove_transition_overlay", get_valid_position())

# WinScreen
func start_win_screen():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_win_screen", get_valid_position())

func deferred_start_win_screen():
	clear_scene()
	var win = win_scene.instance()
	win.connect("start_menu", self, "start_menu")
	add_child(win)
	initiate_fade_to_transparent("remove_transition_overlay", get_valid_position())

# LevelSelect
func start_level_select():
	if not has_node("SceneTransition"):
		initiate_fade_to_black("deferred_start_level_select", get_valid_position())

func deferred_start_level_select():
	clear_scene()
	var level_select = level_select_scene.instance()
	level_select.connect("start_menu", self, "start_menu")
	level_select.connect("start_level", self, "start_level")
	level_select.number_of_levels = len(LEVELS)
	level_select.levels_completed = levels_completed
	add_child(level_select)
	initiate_fade_to_transparent("remove_transition_overlay", get_valid_position())

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
