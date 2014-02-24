extends Node2D

const GRID_ROWS = 10
const GRID_COLS = 10
const CELL_WIDTH = 64

const BLOCK_COUNT = 33
const BLOCK_MOVE_TIME = 2

var blocks = []

var target

var blip
var blip_support
var blip_support_prev_pos

var block_to_destroy

func find_blip_support():
	for block in blocks:
		var block_size = block.get_texture().get_size()
		var block_bounds = Rect2(block.get_global_pos() - block_size / 2, block_size)
		if block_bounds.has_point(blip.get_global_pos()):
			return block
	return null

func cell_pos(row, col):
	return Vector2((col + 0.5) * CELL_WIDTH, (row + 0.5) * CELL_WIDTH)

func cell_is_blocked(row, col):
	if (row < 0 or row >= GRID_ROWS):
		return true
	if (col < 0 or col >= GRID_COLS):
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

func reposition_target():
	var target_block = blocks[randi() % blocks.size()]
	if target_block == blip_support:
		reposition_target()
	else:
		target.get_parent().remove_child(target)
		target_block.add_child(target)

func game_over():
	target.queue_free()
	get_node("title").get_node("fade_in").play("fade_in")
	set_process(false)
	set_process_input(true)

func reset():
	
	# Instantiate blocks
	var block_scene = ResourceLoader.load("res://scenes/block.xml")
	while blocks.size() < BLOCK_COUNT:
		var row = randi() % GRID_ROWS
		var col = randi() % GRID_COLS
		if !cell_is_blocked(row, col):
			var block = block_scene.instance()
			blocks.append(block)
			block.set_pos(cell_pos(row, col))
			block.set_move_dist(CELL_WIDTH)
			get_node("blocks").add_child(block)
			block.connect("move_done", self, "move_block")
			block.place_at(row, col)
			block.begin_wait()
	
	# Instantiate blip
	blip = ResourceLoader.load("res://scenes/blip.xml").instance()
	add_child(blip)
	var starting_block = blocks[randi() % blocks.size()]
	blip.set_pos(starting_block.get_pos())
	blip_support = starting_block
	blip_support_prev_pos = starting_block.get_pos()
	blip.connect("dead", self, "game_over")
	
	# Instantiate target
	target = ResourceLoader.load("res://scenes/target.xml").instance()
	add_child(target) # So first call to reposition_target() doesn't throw an error
	reposition_target()
	
	set_process(true)

func _ready():
	randomize()
	reset()

func _process(delta):

	if blip.is_jumping() or blip.is_dying():
		return
	
	# See if blip is moved by a platform or block
	var new_support = find_blip_support()
	if new_support == null:
		blip.kill()
	else:
		if new_support == blip_support:
			var support_vel = blip_support.get_pos() - blip_support_prev_pos
			blip.set_pos(blip.get_pos() + support_vel)
		else:
			if blip_support == block_to_destroy:
				blip_support.destroy()
				blocks.erase(blip_support)
			blip_support = new_support
			if blip_support == target.get_parent():
				reposition_target()
				block_to_destroy = blip_support
		blip_support_prev_pos = blip_support.get_pos()

func _input(ev):
	var anim_title_fade_in = get_node("title").get_node("fade_in")
	anim_title_fade_in.stop()
	anim_title_fade_in.seek(0, true)
	set_process_input(false)
	reset()
