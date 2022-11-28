extends KinematicBody2D

const START_STOP_FORCE = 3000
const WALK_MAX_SPEED = 300
const PUSH_MAX_SPEED = 100
const JUMP_SPEED = 600
const MASS = 20
const CAYOTE_TIME = 0.1

const LEAN_SPEED = PI / 1024
const MAX_LEAN = PI / 4
const CROUCH_AMOUNT = 8

var current_max_speed = WALK_MAX_SPEED
var velocity = Vector2()
var jumping = false
var falling = false
var cayote_timer = 0.0

var crouching = false
var crouch_angle = 0.0

const PUSH_FUDGE = 50
var push_bodies = []

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

onready var audio = get_tree().get_root().get_node("Audio")

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
		velocity.y += gravity * MASS * delta
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	else:
		var walk = START_STOP_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if abs(walk) < START_STOP_FORCE * 0.2:
			velocity.x = move_toward(velocity.x, 0, START_STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
		velocity.x = clamp(velocity.x, -current_max_speed, current_max_speed)
		velocity.y += gravity * MASS * delta
		update_sprite(velocity)
		# Hack to get around edge cases
		for push_body in push_bodies:
			var collision = move_and_collide(Vector2(velocity.x, 0), true, true, true)
			if collision:
				if collision.collider == push_body:
					var push_collision = push_body.move_and_collide(Vector2(velocity.x, 0), true, true, true)
					if push_collision == null:
						if abs(push_body.position.x - position.x) < PUSH_FUDGE:
							push_body.position.x += sign(velocity.x) * 1
						add_collision_exception_with(push_body)
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
		for body in get_collision_exceptions():
			remove_collision_exception_with(body)
		if is_on_floor() and (jumping or falling):
			$AnimationPlayer.stop()
			$LegSprite.rotation = 0
			audio.play_sound("land")
			$AnimationPlayer.play("Land")
			jumping = false
			falling = false
		if (is_on_floor() or (falling and cayote_timer < CAYOTE_TIME)) and Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP_SPEED
			jumping = true
			falling = false
			$AnimationPlayer.stop()
			$LegSprite.rotation = 0
			audio.play_sound("jump")
			$AnimationPlayer.play("Jump")
		if not is_on_floor() and not jumping and not falling:
			falling = true
			cayote_timer = 0.0
		if falling:
			cayote_timer += delta
	if abs(velocity.x) > 0:
		if not $AnimationPlayer.is_playing() and not falling and not jumping:
			$AnimationPlayer.play("Walk")
	else:
		if $AnimationPlayer.get_current_animation() == "Walk":
			$AnimationPlayer.play("RESET")

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
	$AnimationPlayer.stop()
	$LegSprite.rotation = 0
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

func push_callback(entered, input_push_body):
	if entered:
		push_bodies.append(input_push_body)
		current_max_speed = PUSH_MAX_SPEED
	else:
		push_bodies.erase(input_push_body)
		if len(push_bodies) == 0:
			current_max_speed = WALK_MAX_SPEED
