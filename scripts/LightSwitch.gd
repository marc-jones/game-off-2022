extends Node2D

const FILL_SPEED = 50.0
const FILL_DECAY = 20.0
const SAMPLE_HZ = 22050.0
const MIN_PULSE_HZ = 220.0
const MAX_PULSE_HZ = 500.0
const VOLUME = -25
const BUFFER_LENGTH = 0.1

var total = 0.0
var previous_total = 0.0
var active = false

var phase = 0.0
var playback: AudioStreamPlayback = null

export (NodePath) var target

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	$Fill.set_material($Fill.get_material().duplicate())
	setup_audio()

func detect_light(delta):
	total = clamp(total + delta, 0.0, FILL_SPEED)
	update_fill()

func update_fill():
	$Fill.get_material().set_shader_param("t", total / FILL_SPEED)
	if not active and total == FILL_SPEED:
		active = true
		$Bulb.show()
		audio.play_sound("on")
		$AudioStreamPlayer.stop()
		get_node(target).activate()

func _process(delta):
	if total == previous_total:
		if total < FILL_SPEED:
			total = clamp(total - delta * FILL_DECAY, 0.0, FILL_SPEED)
			update_fill()
	previous_total = total
	_fill_buffer()

func _fill_buffer():
	if 0.0 < total/FILL_SPEED and total/FILL_SPEED < 1.0:
		var increment = (MIN_PULSE_HZ + (MAX_PULSE_HZ-MIN_PULSE_HZ)*(total/FILL_SPEED)) / SAMPLE_HZ
		var to_fill = playback.get_frames_available()
		while to_fill > 0:
			playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
			phase = fmod(phase + increment, 1.0)
			to_fill -= 1
	if total == 0 and $AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.stop()
	if total > 0 and not $AudioStreamPlayer.is_playing() and not active:
		$AudioStreamPlayer.play()

func setup_audio():
	$AudioStreamPlayer.stream.mix_rate = SAMPLE_HZ
	$AudioStreamPlayer.set_volume_db(VOLUME)
	playback = $AudioStreamPlayer.get_stream_playback()
	$AudioStreamPlayer.get_stream().set_buffer_length(BUFFER_LENGTH)
	$AudioStreamPlayer.connect("finished", playback, "clear_buffer")
