extends Node2D

signal transition_finished

var transition_speed = 0.8

var callback_function_str

func _ready():
	$ColorRect.rect_size = $ColorRect.get_viewport_rect().size
	$ColorRect.get_material().set_shader_param("resolution", $ColorRect.rect_size)
	var _discard = $Tween.connect("tween_completed", self, "transition_finished_callback")

func set_to_black():
	$ColorRect.get_material().set_shader_param("t", 0.0)

func set_to_transparent():
	$ColorRect.get_material().set_shader_param("t", 1.0)

func fade_to_black(input_callback_function_str, focus_point):
	$ColorRect.get_material().set_shader_param("center", focus_point)
	$Tween.interpolate_property($ColorRect.get_material(), "shader_param/t", 
		1.0, 0.0, transition_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	callback_function_str = input_callback_function_str

func fade_to_transparent(input_callback_function_str, focus_point):
	$ColorRect.get_material().set_shader_param("center", focus_point)
	$Tween.interpolate_property($ColorRect.get_material(), "shader_param/t", 
		0.0, 1.0, transition_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	callback_function_str = input_callback_function_str

func transition_finished_callback(_object, _key):
	emit_signal("transition_finished", callback_function_str)
