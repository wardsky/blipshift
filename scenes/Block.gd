extends Sprite

const MOVE_TIME = 2
const GRID_VECTOR = Vector2(1, 1)

signal move_done

var move_dist

var position_old : Vector2 setget set_position_old
var position_new : Vector2 setget set_position_new

var move_timer : = 0.0 # Counts down to zero as block moves to dest

func set_position_old(pos: Vector2) -> void:
	position_old = pos.snapped(GRID_VECTOR)

func set_position_new(pos: Vector2) -> void:
	position_new = pos.snapped(GRID_VECTOR)

func set_move_dist(dist):
	move_dist = dist

func place_at(pos: Vector2) -> void:
	set_position_old(pos)
	set_position_new(pos)

func is_blocking(pos: Vector2) -> bool:
	return position_old.distance_squared_to(pos) < 0.1 or position_new.distance_squared_to(pos) < 0.1

func begin_move(dest: Vector2):
	set_position_new(dest)
	move_timer = MOVE_TIME

func begin_wait():
	move_timer = rand_range(0, MOVE_TIME)

func _process(delta):
	if move_timer > 0:
		move_timer -= delta
		if move_timer <= 0:
			set_position_old(position_new)
			emit_signal("move_done", self, position_old)
		else:
			var pos_from = (position_old + Vector2(0.5, 0.5)) * move_dist
			var pos_to = (position_new + Vector2(0.5, 0.5)) * move_dist
			var progress = 1 - clamp(move_timer / MOVE_TIME, 0, 1)
			position = pos_from.linear_interpolate(pos_to, progress)

func destroy():
	$FadeAnimator.play("fade")