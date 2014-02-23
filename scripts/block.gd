extends Sprite

const CELL_SIZE = 64

func cell_pos(row, col):
	return Vector2((col + 0.5) * CELL_SIZE, (row + 0.5) * CELL_SIZE)

const MOVE_TIME = 2

var row_from
var col_from
var row_to
var col_to
var move_timer

func get_pos_from():
	return cell_pos(row_from, col_from)

func get_pos_to():
	return cell_pos(row_to, col_to)

func get_move_progress():
	return clamp(move_timer / MOVE_TIME, 0, 1)

func get_pos():
	return get_pos_from().linear_interpolate(get_pos_to(), get_move_progress())

func dest_reached():
	row_from = row_to
	col_from = col_to
	move_timer = 0

func _ready():
	move_timer = 0
	set_process(true)

func _process(delta):
	move_timer += delta
	if (move_timer >= MOVE_TIME):
		dest_reached()
