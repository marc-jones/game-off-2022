tool
extends KinematicBody2D

var MASS = 10
var pushing_bodies = []
var velocity = Vector2()

export (int) var mirror_angle = 45 setget set_mirror_angle

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$PushAreaLeft.connect("body_entered", self, "body_entered_callback", [-1])
	$PushAreaLeft.connect("body_exited", self, "body_exited_callback", [-1])
	$PushAreaRight.connect("body_entered", self, "body_entered_callback", [1])
	$PushAreaRight.connect("body_exited", self, "body_exited_callback", [1])

func body_entered_callback(body, dir):
	if body.has_method("push_callback"):
		pushing_bodies.append([body, dir])
		body.push_callback(true, self)

func body_exited_callback(body, dir):
	if body.has_method("push_callback"):
		pushing_bodies.erase([body, dir])
		body.push_callback(false, self)

func _physics_process(delta):
	if not Engine.editor_hint:
		velocity.x = 0.0
		velocity.y += gravity * MASS * delta
		for vars in pushing_bodies:
			var body = vars[0]
			var dir = vars[1]
			if body.is_on_floor() and not sign(body.velocity.x) == sign(dir):
				velocity.x = sign(body.velocity.x) * max(abs(body.velocity.x), abs(velocity.x))
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func set_mirror_angle(input_angle):
	mirror_angle = input_angle
	$Mirror.set_rotation_degrees(mirror_angle)
