extends KinematicBody2D

class_name PlayerClass

var up: Vector2 = Vector2(0, -1)

var motion : Vector2 = Vector2(0, 0)
var max_speed = 3
var min_speed = 2
var accel = 0.3
var decel = 0.2

# Angle
var angle_accel = 0.2
var angle_decel = 0.07
var ship_angle = 0.0
var ship_direction : Vector2 = Vector2(0, 0)

# Dash
var dash_direction : Vector2 = Vector2(1, 0)
onready var dash_tween : Tween = get_node("Tweens/DashTween")
var can_dash : bool = false
var dash_power: float = 400 # In pixels
var dash_duration: float = 0.3

# Shoot
onready var shoot_timer : Timer = get_node("Timers/ShootTimer")
var shoot_delay = 10.0
var shooting : bool = false;
var wepon
var bounty 

# Self
var hp_max = 5.0
var hp = hp_max
var fadeout : bool = false

onready var exhaust_timer : Timer = get_node("Timers/ExhaustTimer")
onready var ghost_timer : Timer = get_node("Timers/GhostTimer")
onready var fsm = get_node("StateMachine")


var key_hold = "z"
var key_pack = "alt"
var key_jump = "space"
var key_dash = "shift"
var test = 10
var arr = [0, 1, 2]

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if fsm.state == fsm.MOVE:
		fsm.move()
	elif fsm.state == fsm.DASH:
		fsm.ash()
	elif fsm.state == fsm.SHOOT:
		pass

func update_ship_speed():
	if (Input.is_action_pressed("ui_down")):
		motion.y = max_speed
	elif (Input.is_action_pressed("ui_up")):
		motion.y = -max_speed
	else:
		motion.y = 0
	
	if (Input.is_action_pressed("ui_right")):
		motion.x = max_speed
	elif (Input.is_action_pressed("ui_left")):
		motion.x = min_speed
	else:
		motion.x = 0
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
