extends Sprite

const MOVE_TIME = 2

var row_from
var col_from

var row_to
var col_to

var move_timer = 0 # Counts down to zero as block moves to dest

func place_at(row, col):
	row_from = row
	col_from = col
	row_to = row
	col_to = col

# Normalised position: spacing between cells is 1 unit
func get_norm_pos():
	var progress = 1 - clamp(move_timer / MOVE_TIME, 0, 1)
	return Vector2(col_from, row_from).linear_interpolate(Vector2(col_to, row_to), progress) + Vector2(0.5, 0.5)

func is_blocking(row, col):
	return (row_from == row and col_from == col) or (row_to == row and col_to == col)

func begin_move(dest_row, dest_col):
	row_to = dest_row
	col_to = dest_col
	move_timer = MOVE_TIME

func begin_wait():
	move_timer = rand_range(0, MOVE_TIME)

func _ready():
	add_user_signal("move_done")
	set_process(true)

func _process(delta):
	if move_timer > 0:
		move_timer -= delta
		if move_timer <= 0:
			row_from = row_to
			col_from = col_to
			emit_signal("move_done", self, row_from, col_from)
