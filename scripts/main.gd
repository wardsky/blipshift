extends Node2D

const GRID_ROWS = 10
const GRID_COLS = 10
const CELL_WIDTH = 64

const FILL_RATE = 0.333

const BLOCK_MOVE_TIME = 2

const BLIP_START_ROW = 0
const BLIP_START_COL = 0

var blocks = []

class Block:
	const MOVE_TIME = 2
	var node
	var row_from
	var row_to
	var col_from
	var col_to
	var move_timer # Counts down to zero as block moves to dest
	func get_move_progress():
		return 1 - clamp(move_timer / MOVE_TIME, 0, 1)
	# Normalised position, spacing between cells is 1 unit
	func get_norm_pos():
		return Vector2(col_from, row_from).linear_interpolate(Vector2(col_to, row_to), get_move_progress())
	func update_pos(cell_width):
		node.set_pos((get_norm_pos() + Vector2(0.5, 0.5)) * cell_width)
	func is_blocking(row, col):
		return (row_from == row and col_from == col) or (row_to == row and col_to == col)

var target
var target_row = GRID_ROWS - 1
var target_col = GRID_COLS - 1

func cell_pos(row, col):
	return Vector2((col + 0.5) * CELL_WIDTH, (row + 0.5) * CELL_WIDTH)

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
		if blocks[i].is_blocking(row, col):
			return true
	return false

func _ready():
	
	# Instantiate starting platform
	var platform_scene = ResourceLoader.load("res://scenes/platform.xml")
	var platform = platform_scene.instance()
	platform.add_to_group("supports")
	platform.set_pos(cell_pos(BLIP_START_ROW, BLIP_START_COL))
	add_child(platform)
	
	# Instantiate target
	target = ResourceLoader.load("res://scenes/target.xml").instance()
	target.add_to_group("supports")
	target.set_pos(cell_pos(target_row, target_col))
	add_child(target)
	
	# Instantiate blocks
	var block_scene = ResourceLoader.load("res://scenes/block.xml")
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			if (row == BLIP_START_ROW and col == BLIP_START_COL):
				continue
			if (row == target_row and col == target_col):
				continue
			if (randf() < FILL_RATE):
				var block = Block.new()
				block.node = block_scene.instance()
				block.row_from = row
				block.col_from = col
				block.row_to = row
				block.col_to = col
				block.move_timer = rand_range(0, Block.MOVE_TIME)
				block.update_pos(CELL_WIDTH)
				block.node.add_to_group("supports")
				add_child(block.node)
				blocks.append(block)
	
	# Instantiate blip
	var blip = ResourceLoader.load("res://scenes/blip.xml").instance()
	add_child(blip)
	blip.set_pos(cell_pos(BLIP_START_ROW, BLIP_START_COL))
	
	set_process(true)

func _process(delta):
	for i in range(blocks.size()):
		var block = blocks[i]
		block.move_timer -= delta
		if (block.move_timer < 0):
			block.row_from = block.row_to
			block.col_from = block.col_to
			# Pick a random direction (up, down, left, right)
			var dir = randi() % 4
			var dest_row = block.row_from + [-1, 1, 0, 0][dir]
			var dest_col = block.col_from + [0, 0, -1, 1][dir]
			if (cell_is_blocked(dest_row, dest_col)):
				block.move_timer = rand_range(0, Block.MOVE_TIME)
			else:
				block.row_to = dest_row
				block.col_to = dest_col
				block.move_timer = Block.MOVE_TIME
		block.update_pos(CELL_WIDTH)
