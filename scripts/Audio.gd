extends Node2D

const sound_library = {
	"jump": ["res://assets/sounds/jump.wav", -10, 1.2],
	"land": ["res://assets/sounds/landing.wav", -10, 1.2],
	"on": ["res://assets/sounds/on.wav", -25, 1.0],
	"off": ["res://assets/sounds/off.wav", -25, 1.0],
	"door_open": ["res://assets/sounds/door_open.wav", -10, 1.0],
	"door_close": ["res://assets/sounds/door_close.wav", -10, 1.0]
}

const music_path = preload("res://assets/sounds/Magic Escape Room.mp3")

const music_volume = -10

var stream_library = {
}

func _ready():
	for key in sound_library:
		var random_pitch = AudioStreamRandomPitch.new()
		random_pitch.set_audio_stream(load(sound_library[key][0]))
		random_pitch.set_random_pitch(sound_library[key][2])
		var sound_node = AudioStreamPlayer.new()
		sound_node.set_stream(random_pitch)
		sound_node.volume_db = sound_library[key][1]
		add_child(sound_node)
		stream_library[key] = sound_node
	$Music.volume_db = music_volume
	$Music.set_stream(music_path)
	$Music.play()

func play_sound(sound_str):
	if sound_str in stream_library:
		stream_library[sound_str].play()
