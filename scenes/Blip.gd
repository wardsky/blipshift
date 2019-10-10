extends Node2D

signal dead

const MOVE_SPEED = 48
const JUMP_DISTANCE = 64
const JUMP_SPEED = 64 / 0.2
const DOUBLE_TAP_TIMEOUT = 0.2

var double_tap_timer = 0

var jump_action

func is_jumping():
	return $JumpAnimator.is_playing()

func is_dying():
	return $DeathAnimator.is_playing()

func revive():
	set_process(true)
	$DeathAnimator.seek(0, true)
	jump_action = "none"

func kill():
	set_process(false)
	$HorizontalMoveAnimator.stop()
	$VerticalMoveAnimator.stop()
	$DeathAnimator.play("die")

func _process(delta):
	var vel = Vector2(0, 0)
	var speed_magnitude = 0
	if not $JumpAnimator.is_playing():
		speed_magnitude = MOVE_SPEED
	else:
		speed_magnitude = JUMP_SPEED
	
	if Input.is_action_pressed("ui_up") || (jump_action == "jump_up" && is_jumping()):
		vel.y = -speed_magnitude * delta
	elif Input.is_action_pressed("ui_down") || (jump_action == "jump_down" && is_jumping()):
		vel.y = speed_magnitude * delta
	else:
		vel.y = 0
	if Input.is_action_pressed("ui_left") || (jump_action == "jump_left" && is_jumping()):
		vel.x = -speed_magnitude * delta
	elif Input.is_action_pressed("ui_right") || (jump_action == "jump_right" && is_jumping()):
		vel.x = speed_magnitude * delta
	else:
		vel.x = 0
	
	position += vel
	if double_tap_timer > 0:
		double_tap_timer -= delta

func _input(ev: InputEvent):
	if not ev is InputEventKey:
		return
	if $JumpAnimator.is_playing():
		return
	var jump_action_maybe = "none"
	if !ev.is_echo():
		if ev.is_pressed():
			print("is_pressed")
			if ev.is_action("ui_up"):
				$VerticalMoveAnimator.play("move_vertical")
			elif ev.is_action("ui_down"):
				$VerticalMoveAnimator.play("move_vertical")
			elif ev.is_action("ui_left"):
				$HorizontalMoveAnimator.play("move_horizontal")
			elif ev.is_action("ui_right"):
				$HorizontalMoveAnimator.play("move_horizontal")
		else:
			if ev.is_action("ui_up"):
				$VerticalMoveAnimator.stop()
				jump_action_maybe = "jump_up"
			elif ev.is_action("ui_down"):
				$VerticalMoveAnimator.stop()
				jump_action_maybe = "jump_down"
			elif ev.is_action("ui_left"):
				$HorizontalMoveAnimator.stop()
				jump_action_maybe = "jump_left"
			elif ev.is_action("ui_right"):
				$HorizontalMoveAnimator.stop()
				jump_action_maybe = "jump_right"
			if jump_action_maybe != "none":
				if double_tap_timer > 0 and jump_action == jump_action_maybe:
					$JumpAnimator.play(jump_action)
					double_tap_timer = -1
				else:
					double_tap_timer = DOUBLE_TAP_TIMEOUT
					jump_action = jump_action_maybe


func _on_DeathAnimator_animation_finished(anim_name):
	emit_signal("dead")

func _on_JumpAnimator_animation_finished(anim_name):
	jump_action = "none"
	$JumpAnimator.seek(0, true)
