extends Node2D

func _ready():
	$Fill.get_material().set_shader_param("t", 0.0)

func activate():
	$AnimationPlayer.play("Open")

func deactivate():
	$AnimationPlayer.stop(false)
	$AnimationPlayer.play_backwards("Open")
