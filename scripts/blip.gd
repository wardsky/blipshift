extends Node2D

const MOVE_SPEED = 32
const JUMP_DISTANCE = 64
const DOUBLE_TAP_TIMEOUT = 0.2

var double_tap_timer = 0

var anim_move_up_down
var anim_move_left_right
var anim_jump

var jump_action

func is_jumping():
	return anim_jump.is_playing()

func _jump_finished():
	if jump_action == "jump_up":
		set_pos(get_pos() + Vector2(0, -JUMP_DISTANCE))
	elif jump_action == "jump_down":
		set_pos(get_pos() + Vector2(0, JUMP_DISTANCE))
	elif jump_action == "jump_left":
		set_pos(get_pos() + Vector2(-JUMP_DISTANCE, 0))
	elif jump_action == "jump_right":
		set_pos(get_pos() + Vector2(JUMP_DISTANCE, 0))
	anim_jump.seek(0, true)

func _ready():
	anim_move_up_down = get_node("anim_move_up_down")
	anim_move_left_right = get_node("anim_move_left_right")
	anim_jump = get_node("anim_jump")
	set_process(true)
	set_process_input(true)

func _process(delta):
	if !anim_jump.is_playing():
		var vel = Vector2(0, 0)
		if Input.is_action_pressed("move_up"):
			vel.y = -MOVE_SPEED * delta
		elif Input.is_action_pressed("move_down"):
			vel.y = MOVE_SPEED * delta
		else:
			vel.y = 0
		if Input.is_action_pressed("move_left"):
			vel.x = -MOVE_SPEED * delta
		elif Input.is_action_pressed("move_right"):
			vel.x = MOVE_SPEED * delta
		else:
			vel.x = 0
		set_pos(get_pos() + vel)
	if double_tap_timer > 0:
		double_tap_timer -= delta

func _input(ev):
	var jump_action_maybe = "none"
	if !ev.is_echo():
		if ev.is_pressed():
			if ev.is_action("move_up"):
				anim_move_up_down.play("move_up")
			elif ev.is_action("move_down"):
				anim_move_up_down.play("move_down")
			elif ev.is_action("move_left"):
				anim_move_left_right.play("move_left")
			elif ev.is_action("move_right"):
				anim_move_left_right.play("move_right")
		else:
			if ev.is_action("move_up"):
				anim_move_up_down.stop()
				jump_action_maybe = "jump_up"
			elif ev.is_action("move_down"):
				anim_move_up_down.stop()
				jump_action_maybe = "jump_down"
			elif ev.is_action("move_left"):
				anim_move_left_right.stop()
				jump_action_maybe = "jump_left"
			elif ev.is_action("move_right"):
				anim_move_left_right.stop()
				jump_action_maybe = "jump_right"
			if !anim_jump.is_playing():
				if double_tap_timer > 0 and jump_action == jump_action_maybe:
					anim_jump.play(jump_action)
					anim_jump.connect("finished", self, "_jump_finished", [], CONNECT_ONESHOT)
				else:
					double_tap_timer = DOUBLE_TAP_TIMEOUT
					jump_action = jump_action_maybe
