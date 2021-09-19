extends PlayerClass

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {
	MOVE,
	DASH,
	SHOOT
}
var state = MOVE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if state == MOVE:
#		move()
#	elif state == DASH:
#		dash()
#	elif state == SHOOT:
#		pass
	pass		
func move():
#	var my_lambda = func(x): print(x)
	if (exhaust_timer.time_left == 0): exhaust_timer.start(0.1)
	update_ship_speed()
	ship_direction = Vector2(Global.input_direction.x, Global.input_direction.y)
	
	if (Input.is_action_pressed("key_dash")):
		if can_dash:
			if (abs(Global.input_direction.x) or abs(Global.input_direction.y)):
				dash_direction = Vector2(Global.input_direction.x, -Global.input_direction.y)
			else:
				dash_direction = Vector2(sign(motion.x), 0)
			dash_tween.interpolate_property(self, "motion", motion, motion + dash_direction * dash_power, dash_duration, 
								Tween.TRANS_QUINT, Tween.EASE_OUT)
			dash_tween.start()
			change(DASH)
		can_dash = false
	else:
		can_dash = true
	motion = move_and_slide(motion, up)

func dash():
	if (!dash_tween.is_active()):
		dash_tween.reset(self, "motion")
		dash_tween.start()
	if (ghost_timer.is_paused()): ghost_timer.start(0.05)
	yield(dash_tween, "tween_completed")
	dash_tween.stop(self, "motion")
	dash_tween.reset(self, "motion")
	motion = move_and_slide(motion, up)
	

func change(next):
	state = next;
	
	
func _on_GhostTimer_timeout():
	pass
