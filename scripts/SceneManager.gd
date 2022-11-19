extends Node2D

const menu_scene = preload("res://nodes/scenes/MainMenu.tscn")
const level_select_scene = preload("res://nodes/scenes/LevelSelect.tscn")
const credits_scene = preload("res://nodes/scenes/Credits.tscn")
const scene_transition = preload("res://nodes/scenes/SceneTransition.tscn")

func _ready():
	deferred_start_menu()

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
