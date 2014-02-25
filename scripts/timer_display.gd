extends Node

const TIME_FULL = 60
const TIME_BONUS = 10

var time
var time_limit

var digit_hundreds
var digit_tens
var digit_ones
var digit_tenths
var digit_hundredths
var digit_thousandths

var bar
var bar_full_length
var bar_thickness

func start():
	time = 0
	time_limit = TIME_FULL
	digit_hundreds.hide()
	digit_tens.hide()
	set_process(true)

func stop():
	set_process(false)

func extend_time():
	time_limit += TIME_BONUS

func _ready():
	digit_hundreds = get_node("time_counter/hundreds")
	digit_tens = get_node("time_counter/tens")
	digit_ones = get_node("time_counter/ones")
	digit_tenths = get_node("time_counter/tenths")
	digit_hundredths = get_node("time_counter/hundredths")
	digit_thousandths = get_node("time_counter/thousandths")
	bar = get_node("timer_bar")
	bar_full_length = bar.get_region_rect().size.width
	bar_thickness = bar.get_region_rect().size.height
	add_user_signal("timeout")

func _process(delta):
	time += delta
	
	if time > time_limit:
		emit_signal("timeout")
		return
	
	# Update time counter display
	if time >= 100:
		digit_hundreds.show()
		digit_hundreds.set_frame(fmod(time / 100, 10))
	if time >= 10:
		digit_tens.show()
		digit_tens.set_frame(fmod(time / 10, 10))
	digit_ones.set_frame(fmod(time, 10))
	digit_tenths.set_frame(fmod(time * 10, 10))
	digit_hundredths.set_frame(fmod(time * 100, 10))
	digit_thousandths.set_frame(fmod(time * 1000, 10))
	
	# Update bar length
	var bar_length = clamp(bar_full_length * (time_limit - time) / TIME_FULL, 0, bar_full_length)
	bar.set_region_rect(Rect2(Vector2(0, 0), Vector2(bar_length, bar_thickness)))
