extends Sprite

const MOVE_TIME = 2

var move_dist

var row_from
var col_from

var row_to
var col_to

var move_timer = 0 # Counts down to zero as block moves to dest

func set_move_dist(dist):
	move_dist = dist

func place_at(row, col):
	row_from = row
	col_from = col
	row_to = row
	col_to = col

func is_blocking(row, col):
	return (row_from == row and col_from == col) or (row_to == row and col_to == col)

func begin_move(dest_row, dest_col):
	row_to = dest_row
	col_to = dest_col
	move_timer = MOVE_TIME

func begin_wait():
	move_timer = rand_range(0, MOVE_TIME)

func destroy():
	var anim_fade = get_node("anim_fade")
	anim_fade.connect("finished", self, "queue_free")
	anim_fade.play("fade")

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
		else:
			var pos_from = Vector2(col_from + 0.5, row_from + 0.5) * move_dist
			var pos_to = Vector2(col_to + 0.5, row_to + 0.5) * move_dist
			var progress = 1 - clamp(move_timer / MOVE_TIME, 0, 1)
			set_pos(pos_from.linear_interpolate(pos_to, progress))
