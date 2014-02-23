extends Node2D

const GRID_ROWS = 10
const GRID_COLS = 10
const CELL_WIDTH = 64

const FILL_RATE = 0.333

const BLOCK_MOVE_TIME = 2

const BLIP_START_ROW = 0
const BLIP_START_COL = 0

var blocks = []

var target
var target_row = GRID_ROWS - 1
var target_col = GRID_COLS - 1

var blip
var blip_support
var blip_support_prev_pos

func find_blip_support(result):
	for node in get_children():
		if !node.is_in_group("supports"):
			continue
		var node_size = node.get_texture().get_size()
		var node_bounds = Rect2(node.get_global_pos() - node_size / 2, node_size)
		if node_bounds.has_point(blip.get_global_pos()):
			result["node"] = node
			return true
	return false

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

func move_block(block, block_row, block_col):
	# Pick a random direction (up, down, left, right)
	var dir = randi() % 4
	var dest_row = block_row + [-1, 1, 0, 0][dir]
	var dest_col = block_col + [0, 0, -1, 1][dir]
	if (cell_is_blocked(dest_row, dest_col)):
		block.begin_wait()
	else:
		block.begin_move(dest_row, dest_col)

func _ready():
	
	# Instantiate starting platform
	var platform = ResourceLoader.load("res://scenes/platform.xml").instance()
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
				var block = block_scene.instance()
				blocks.append(block)
				block.add_to_group("supports")
				block.set_pos(cell_pos(row, col))
				add_child(block)
				block.connect("move_done", self, "move_block")
				block.place_at(row, col)
				block.begin_wait()
	
	# Instantiate blip
	blip = ResourceLoader.load("res://scenes/blip.xml").instance()
	add_child(blip)
	blip.set_pos(cell_pos(BLIP_START_ROW, BLIP_START_COL))
	blip_support = platform
	blip_support_prev_pos = platform.get_pos()
	
	set_process(true)

func _process(delta):
	
	# Update block positions
	for block in blocks:
		block.set_pos(block.get_norm_pos() * CELL_WIDTH)
	
	# See if blip is moved by a platform or block
	var support_result = {}
	if !blip.is_jumping() and find_blip_support(support_result):
		if support_result["node"] == blip_support:
			var support_vel = blip_support.get_pos() - blip_support_prev_pos
			blip.set_pos(blip.get_pos() + support_vel)
		else:
			blip_support = support_result["node"]
		blip_support_prev_pos = blip_support.get_pos()
