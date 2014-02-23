extends Node2D

const GRID_ROWS = 10
const GRID_COLS = 10
const CELL_SIZE = 64

const FILL_RATE = 0.333

const BLOCK_MOVE_TIME = 2

const BLIP_START_ROW = 0
const BLIP_START_COL = 0

var blocks = []
var block_row_from = []
var block_row_to = []
var block_col_from = []
var block_col_to = []
var block_move_timer = [] # Counts down to zero as block moves to dest

class Block:
	const MOVE_TIME = 2
	var sprite
	var row_from
	var row_to
	var col_from
	var col_to
	var move_timer # Counts down to zero as block moves to dest
	func get_pos_from():
		return cell_pos(row_from, col_from)
	func get_pos_to():
		return cell_pos(row_to, col_to)
	func get_move_progress():
		return 1 - clamp(move_timer / MOVE_TIME, 0, 1)
	func get_pos():
		return get_pos_from().linear_interpolate(get_pos_to(), get_move_progress())

var target
var target_row = GRID_ROWS - 1
var target_col = GRID_COLS - 1

func cell_pos(row, col):
	return Vector2((col + 0.5) * CELL_SIZE, (row + 0.5) * CELL_SIZE)

func cell_is_blocked(row, col):
	if (row < 0 or row >= GRID_ROWS):
		return true
	if (col < 0 or col >= GRID_COLS):
		return true
	if (row == BLIP_START_ROW and col == BLIP_START_COL):
		return true
	if (row == target_row and col == target_col):
		return true
	for i in range(blocks.size()):
		if (block_row_from[i] == row and block_col_from[i] == col):
			return true
		if (block_row_to[i] == row and block_col_to[i] == col):
			return true
	return false

func block_pos_from(i):
	return cell_pos(block_row_from[i], block_col_from[i])

func block_pos_to(i):
	return cell_pos(block_row_to[i], block_col_to[i])

func block_update_pos(i):
	blocks[i].set_pos(block_pos_to(i).linear_interpolate(block_pos_from(i), block_move_timer[i] / BLOCK_MOVE_TIME))

func _ready():
	
	# Instantiate starting platform
	var platform_scene = ResourceLoader.load("res://scenes/platform.xml")
	var platform = platform_scene.instance()
	add_child(platform)
	platform.set_pos(cell_pos(BLIP_START_ROW, BLIP_START_COL))
	
	# Instantiate target
	target = ResourceLoader.load("res://scenes/target.xml").instance()
	add_child(target)
	target.set_pos(cell_pos(target_row, target_col))
	
	# Instantiate blocks
	var block_scene = ResourceLoader.load("res://scenes/block.xml")
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			if (row == BLIP_START_ROW and col == BLIP_START_COL):
				continue
			if (row == target_row and col == target_col):
				continue
			if (randf() < FILL_RATE):
				var block = block_scene.instance()
				blocks.append(block)
				add_child(block)
				block.set_pos(cell_pos(row, col))
				block_row_from.append(row)
				block_row_to.append(row)
				block_col_from.append(col)
				block_col_to.append(col)
				block_move_timer.append(rand_range(0, BLOCK_MOVE_TIME))
	
	# Instantiate blip
	var blip = ResourceLoader.load("res://scenes/blip.xml").instance()
	add_child(blip)
	blip.set_pos(cell_pos(BLIP_START_ROW, BLIP_START_COL))
	
	set_process(true)

func _process(delta):

	for i in range(blocks.size()):
		block_move_timer[i] -= delta
		if (block_move_timer[i] > 0):
			block_update_pos(i)
		else:
			blocks[i].set_pos(block_pos_to(i))
			block_row_from[i] = block_row_to[i]
			block_col_from[i] = block_col_to[i]
			# Pick a random direction (up, down, left, right)
			var dir = randi() % 4
			var dest_row = block_row_from[i] + [-1, 1, 0, 0][dir]
			var dest_col = block_col_from[i] + [0, 0, -1, 1][dir]
			if (cell_is_blocked(dest_row, dest_col)):
				block_move_timer[i] = rand_range(0, BLOCK_MOVE_TIME)
			else:
				block_row_to[i] = dest_row
				block_col_to[i] = dest_col
				block_move_timer[i] = BLOCK_MOVE_TIME
