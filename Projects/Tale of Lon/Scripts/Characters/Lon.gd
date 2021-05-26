extends KinematicBody2D
var up: Vector2 = Vector2(0, -1)
var gravity: float = 8

var max_fall_speed = 175
var max_speed = 150
var accel = 8
var decel = 10

var jump_force = 300
var can_jump : bool = false
var coyote : float = 0.00
var coyote_max = 7
var jump_buffer : float = 0.00
var jump_buffer_max = 6

var on_ground : bool = false
var on_wall = false

export var gas_max = 200
var gas : float = gas_max
var gas_rate : float = gas / gas_max
var pack_power : float = 0.00
var pack_power_max = 15

var dash_power: float = 500
var dash_duration: float = 0.25
var dash_count_max: int = 3
var dash_count: int = dash_count_max
var is_dashing: bool = false


var facing = 1
var last_facing = facing

var motion : Vector2 = Vector2()
var direction: Vector2 = Vector2()

enum {
	MOVE,
	CROUCH,
	HOLD,
	JUMP,
	DASH,
	FLY
}
var state = MOVE

var key_hold = "z"
var key_pack = "alt"
var key_jump = "space"
var key_dash = "shift"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	pass

func _physics_process(delta):
	pass

# States

# Functions





















