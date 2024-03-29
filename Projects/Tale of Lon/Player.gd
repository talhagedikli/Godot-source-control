extends KinematicBody2D

var up: Vector2 = Vector2(0, -1)
var gravity: float = 8

var maxFallSpeed = 175
var maxSpeed = 150
var accel = 8
var decel = 10

var jumpForce = 300
var canJump : bool = false
var coyote : float = 0.00
var coyoteMax = 7
var jumpBuffer : float = 0.00
var jumpBufferMax = 6

var onGround : bool = false
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

onready var body : Sprite = get_node("Pivot/Sprite")

onready var raycastBottom : RayCast2D = $Collisions/BottomCollision
onready var raycastTop : RayCast2D = $Collisions/TopCollision
onready var raycastLeft : RayCast2D = $Collisions/LeftCollision
onready var raycastRight : RayCast2D = $Collisions/RightCollision

onready var dashTween : Tween = $Tween

onready var playerUI = get_parent().get_node("PlayerUI")

signal using_pack
signal dashed

func _ready():
	pass

func _physics_process(delta):
#	onGround = raycastBottom.is_colliding()
#	if raycastRight.is_colliding() or raycastLeft.is_colliding():
#		on_wall = true
#	else:
#		on_wall = false
	onGround = is_on_floor()
	on_wall = is_on_wall()


	if state == MOVE:
		player_state_move()
	elif state == CROUCH:
		player_state_crouch()
	elif state == HOLD:
		player_state_hold()
	elif state == DASH:
		player_state_dash()
	
	motion = move_and_slide(motion, up)

	#Calculate facing
	if motion.x > 0: facing = 1
	elif motion.x < 0: facing = -1
	else: facing = facing
	
	#Animation
#	body.scale.x = GlobalFunc.approach(body.scale.x, 1, 0.05)
#	body.scale.y = GlobalFunc.approach(body.scale.y, 1, 0.05)

#States
func player_state_move():
	if Input.is_action_pressed("right"):
		motion.x += accel
	elif Input.is_action_pressed("left"):
		motion.x -= accel
	else:
		motion.x = lerp(motion.x, 0, 0.1)
	
	# Jump 
	if !onGround:
		if coyote > 0:
			coyote -= 1
	else:
		coyote = coyoteMax
		dash_count = dash_count_max

	if (Input.is_action_pressed(key_jump) && canJump && coyote > 0):
		if coyote > 0:
			motion.y = -jumpForce
			canJump = false
			squashAndStretch(0.6, 1.4)
	elif (!Input.is_action_pressed(key_jump) && onGround):
		canJump = true

	if Input.is_action_just_pressed(key_jump): jumpBuffer = jumpBufferMax
	
	if jumpBuffer > 0:
		jumpBuffer -= 1
		if onGround:
			jumpBuffer = 0
			motion.y = -jumpForce
			squashAndStretch(0.6, 1.4)
	
	if !onGround: # Apply gravity and make variable jump
		if (motion.y < 0) && (!Input.is_action_pressed(key_jump) && (!Input.is_action_pressed(key_pack))):
			motion.y *= 0.8
		motion.y += gravity
	
	last_facing = facing
	
	motion.x = clamp(motion.x, -maxSpeed, maxSpeed)
	motion.y = clamp(motion.y, -maxFallSpeed, maxFallSpeed)
	
	# Switch statement
	if Input.is_action_just_pressed(key_hold) && on_wall: change_state(HOLD)
#	if Input.is_action_pressed("down") && onGround: change_state(CROUCH)
	if Input.is_action_just_pressed(key_dash) && dash_count > 0 && !is_dashing && !dashTween.is_active(): 
		find_direction(false)
		dash_count -= 1
		emit_signal("dashed", true)
		motion = Vector2.ZERO
		if direction == Vector2.ZERO: direction.x = last_facing
		dashTween.interpolate_property(self, "motion", motion, motion + direction * dash_power, dash_duration, Tween.TRANS_QUINT, Tween.EASE_OUT)
		dashTween.start()
		$Effects/GhostTimer.start(dash_duration / 6)
		change_state(DASH)
	# Set UI variables

func player_state_jump():
	if !onGround:
		if coyote > 0:
			coyote -= 1
	else:
		coyote = coyoteMax

	if (Input.is_action_pressed(key_jump) && canJump && coyote > 0):
		motion.y = -jumpForce
		canJump = false
		squashAndStretch(0.6, 1.4)
	elif (!Input.is_action_pressed(key_jump) && onGround):
		canJump = true

	if Input.is_action_just_pressed(key_jump): jumpBuffer = jumpBufferMax
	
	if jumpBuffer > 0:
		jumpBuffer -= 1
		if onGround:
			jumpBuffer = 0
			motion.y = -jumpForce
			squashAndStretch(0.6, 1.4)

func player_state_crouch():
	motion = lerp(motion, Vector2.ZERO, 0.01)
	squashAndStretch(1.4, 0.6)
	if !Input.is_action_pressed("down"):
		change_state(MOVE)
	
func player_state_fly():
	pass

func player_state_hold():
	if raycastRight.is_colliding(): facing = -1
	else: facing = 1
	motion.x = 0
	motion.y = lerp(motion.y, 0, 0.2)
	if Input.is_action_just_pressed(key_jump): #Walljump
		motion.x = jumpForce * facing * 0.7
		motion.y = -jumpForce * 0.8
		facing = last_facing
		change_state(MOVE)
	if Input.is_action_just_released(key_hold): #Falldown
		facing = last_facing
		change_state(MOVE)

func player_state_dash():
	is_dashing = true
	if on_wall && direction.x != 0: 
		dashTween.reset(self, "motion")
		$Effects/GhostTimer.stop()
		change_state(MOVE)

	if ((abs(direction.x) + abs(direction.y)) != 2):
		squashAndStretch(abs(direction.x)/5 + 1, abs(direction.y)/5 + 1)

	yield(dashTween, "tween_completed")
	dashTween.reset(self, "motion")
	$Effects/GhostTimer.stop()
	motion *= 0.4
	find_direction(false)
	is_dashing = false
	change_state(MOVE)

#Functions
func change_state(new_state):
	state = new_state

func squashAndStretch(xscale: float, yscale: float):
	body.scale.x = xscale
	body.scale.y = yscale

func find_direction(also_facing: bool):
	if Input.is_action_pressed("right"):
		direction.x = 1
	elif Input.is_action_pressed("left"):
		direction.x = -1
	else:
		direction.x = 0
	# If you want to change players facing by pressing right/left directly
	if also_facing:
		facing = direction.x
	
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"):
		direction.y = 1
	else:
		direction.y = 0

func frame_freeze(duration: float):
	OS.delay_msec(duration)

#Signals

