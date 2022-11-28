extends Node2D

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	$Fill.get_material().set_shader_param("t", 0.0)

func activate():
	$AnimationPlayer.play("Open")

func deactivate():
	$AnimationPlayer.stop(false)
	$AnimationPlayer.play_backwards("Open")

func play_sound():
	if $AnimationPlayer.get_playing_speed() < 0:
		audio.play_sound("door_close")
	else:
		audio.play_sound("door_open")
