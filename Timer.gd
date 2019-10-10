extends Node2D

signal timeout

const TIME_FULL : = 60
const TIME_BONUS : = 10

var time : float = 0
var time_limit : float = TIME_FULL

onready var digit_hundreds : Sprite = $TimerDisplay/Hundreds
onready var digit_tens : Sprite = $TimerDisplay/Tens
onready var digit_ones : Sprite = $TimerDisplay/Ones
onready var digit_tenths : Sprite = $TimerDisplay/Tenths
onready var digit_hundredths : Sprite = $TimerDisplay/Hundredths
onready var digit_thousandths : Sprite = $TimerDisplay/Thousandths

onready var bar : ProgressBar = $MarginContainer/ProgressBar

func start() -> void:
	time = 0
	time_limit = TIME_FULL
	digit_hundreds.hide()
	digit_tens.hide()
	set_process(true)

func stop() -> void:
	set_process(false)

func extend_time() -> void:
	time_limit += TIME_BONUS

func _ready() -> void:
	set_process(false)

func _process(delta) -> void:
	time += delta
	
	if time > time_limit:
		time = time_limit
		emit_signal("timeout")
	
	# Update time counter display
	if time >= 100:
		digit_hundreds.show()
		digit_hundreds.set_frame(fmod(time / 100, 10))
	else:
		digit_hundreds.hide()
	if time >= 10:
		digit_tens.show()
		digit_tens.set_frame(fmod(time / 10, 10))
	else:
		digit_tens.hide()
	digit_ones.set_frame(fmod(time, 10))
	digit_tenths.set_frame(fmod(time * 10, 10))
	digit_hundredths.set_frame(fmod(time * 100, 10))
	digit_thousandths.set_frame(fmod(time * 1000, 10))
	
	bar.value = time_limit - time