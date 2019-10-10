extends Node2D

const GRID_SIZE : = Vector2(10, 10)
var GRID_RECT : = Rect2(Vector2(0, 0), GRID_SIZE)

const BLOCK_COUNT : = 33
const BLOCK_MOVE_TIME : = 2

const Block = preload("res://scenes/Block.tscn")

onready var cell_width: float = get_viewport_rect().size.x / GRID_SIZE.x
onready var title_animation_player: AnimationPlayer = $Overlay/Title/AnimationPlayer
const blocks : = []

onready var target : Sprite = $PlayerObjects/Target
onready var blip : Node2D = $PlayerObjects/Blip
onready var timer = $Overlay/Timer

var blip_support : Sprite
var blip_support_prev_pos : Vector2

var block_to_destroy : Sprite

func _ready() -> void:
	randomize()
	set_process(false)
	timer.connect("timeout", self, "game_over")
	begin_game()


func begin_game() -> void:
	
	while blocks.size() < BLOCK_COUNT:
		var row = randi() % int(GRID_SIZE.y)
		var col = randi() % int(GRID_SIZE.x)
		var grid_position : = Vector2(row, col)
		if not cell_is_blocked(grid_position):
			var block = Block.instance()
			blocks.append(block)
			block.position = cell_pos(grid_position)
			block.set_move_dist(cell_width)
			$Blocks.add_child(block)
			block.connect("move_done", self, "_on_Block_move_done")
			block.place_at(grid_position)
			block.begin_wait()

	title_animation_player.play("fade_in")
	set_process_input(true)

func cell_pos(grid_posision: Vector2) -> Vector2:
	return (grid_posision + Vector2(0.5, 0.5)) * cell_width

func cell_is_blocked(grid_posision: Vector2) -> bool:
	if not GRID_RECT.has_point(grid_posision):
		return true
	for block in blocks:
		if block.is_blocking(grid_posision):
			return true
	return false

func find_blip_support() -> Sprite:
	for block in blocks:
		var block_size = block.get_texture().get_size()
		var block_bounds = Rect2(block.global_position - block_size / 2, block_size)
		if block_bounds.has_point(blip.global_position):
			return block
	return null

func reposition_target() -> void:
	if blocks.size() == 1:
		game_over()
		return
	var target_block = blocks[randi() % blocks.size()]
	if target_block == blip_support:
		reposition_target()
	else:
		target.get_parent().remove_child(target)
		target_block.add_child(target)

func game_over() -> void:
	blip.kill()
	timer.stop()
	target.hide()
	set_process(false)


func reset() -> void:

	# Instantiate blip
	var starting_block = blocks[randi() % blocks.size()]
	blip.position = starting_block.position
	blip.revive()
	blip_support = starting_block
	blip_support_prev_pos = starting_block.position

	# Instantiate target
	target.show()
	reposition_target()

	# Set timer running
	timer.start()

	set_process(true)

func _process(delta) -> void:

	if $PlayerObjects/Blip.is_jumping() or blip.is_dying():
		return

	# See if blip is moved by a platform or block
	var new_support = find_blip_support()
	if new_support == null:
		game_over()
	else:
		if new_support == blip_support:
			var support_vel = blip_support.position - blip_support_prev_pos
			blip.position += support_vel
		else:
			if blip_support == block_to_destroy:
				blocks.erase(blip_support)
				blip_support.destroy()
			blip_support = new_support
			if blip_support == target.get_parent():
				timer.extend_time()
				reposition_target()
				block_to_destroy = blip_support
		blip_support_prev_pos = blip_support.position

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		title_animation_player.stop()
		title_animation_player.seek(0, true)
		set_process_input(false)
		reset()

func _on_Block_move_done(block, grid_position: Vector2) -> void:
	var rand : = randi() % 4
	var delta : = Vector2(0, 1).rotated(PI / 2 * rand)
	var direction : = grid_position + delta
	if (cell_is_blocked(direction)):
		block.begin_wait()
	else:
		block.begin_move(direction)

func _on_Blip_dead():
	begin_game()
