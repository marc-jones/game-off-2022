extends KinematicBody2D

const START_STOP_FORCE = 3000
const WALK_MAX_SPEED = 300
const JUMP_SPEED = 600
const MASS = 20
const CAYOTE_TIME = 0.1
const shiny = true

var velocity = Vector2()
var jumping = false
var falling = false
var cayote_timer = 0.0

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var walk = START_STOP_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	if abs(walk) < START_STOP_FORCE * 0.2:
		velocity.x = move_toward(velocity.x, 0, START_STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	velocity.y += gravity * MASS * delta
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	if is_on_floor() and (jumping or falling):
		jumping = false
		falling = false
	if (is_on_floor() or (falling and cayote_timer < CAYOTE_TIME)) and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
		jumping = true
		falling = false
	if not is_on_floor() and not jumping and not falling:
		falling = true
		cayote_timer = 0.0
	if falling:
		cayote_timer += delta
