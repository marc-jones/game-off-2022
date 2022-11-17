extends KinematicBody2D

const START_STOP_FORCE = 3000
const WALK_MAX_SPEED = 300
const JUMP_SPEED = 600
const MASS = 20
const CAYOTE_TIME = 0.1

const LEAN_SPEED = PI / 1024
const MAX_LEAN = PI / 4
const CROUCH_AMOUNT = 8

var velocity = Vector2()
var jumping = false
var falling = false
var cayote_timer = 0.0

var crouching = false
var crouch_angle = 0.0

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		crouching = true
		crouch()
	if Input.is_action_just_released("crouch"):
		crouching = false
		uncrouch()
	if crouching:
		crouch_angle += LEAN_SPEED * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		crouch_angle = clamp(crouch_angle, -MAX_LEAN, MAX_LEAN)
		crouch_rotate()
		velocity.x = 0.0
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	else:
		var walk = START_STOP_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if abs(walk) < START_STOP_FORCE * 0.2:
			velocity.x = move_toward(velocity.x, 0, START_STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
		velocity.y += gravity * MASS * delta
		update_sprite(velocity)
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

func update_sprite(current_velocity):
	if current_velocity.x < 0:
		face_left()
	elif current_velocity.x > 0:
		face_right()

func face_left():
	$LegSprite.flip_h = false
	$BodySprite.flip_h = false

func face_right():
	$LegSprite.flip_h = true
	$BodySprite.flip_h = true

func crouch():
	$BodySprite.position.y = CROUCH_AMOUNT
	$Area2D.position.y = CROUCH_AMOUNT

func uncrouch():
	crouch_angle = 0.0
	crouch_rotate()
	$BodySprite.position.y = 0
	$Area2D.position.y = 0

func crouch_rotate():
	$BodySprite.rotation = crouch_angle
	$Area2D.rotation = crouch_angle
