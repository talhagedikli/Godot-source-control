extends KinematicBody2D

var up: Vector2 = Vector2(0, -1)
var gravity: float = 8
var time: float = OS.get_system_time_secs()

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

var dash_power: float = 150
var dash_duration: float = 0.25
var dash_count_max: int = 2
var dash_count: int = dash_count_max


var facing = 1
var last_facing = facing

var motion : Vector2 = Vector2()
var direction: Vector2 = Vector2()

enum {
	MOVE,
	HOLD,
	JUMP,
	DASH,
	FLY
}
var state = MOVE

var key_hold = "z"
var key_pack = "alt"
var key_jump = "space"
var key_dash = "x"

onready var pivot = get_node("Pivot")
onready var body : Sprite = get_node("Pivot/Sprite")

onready var raycastBottom : RayCast2D = $Collisions/BottomCollision
onready var raycastTop : RayCast2D = $Collisions/TopCollision
onready var raycastLeft : RayCast2D = $Collisions/LeftCollision
onready var raycastRight : RayCast2D = $Collisions/RightCollision

onready var dashTween : Tween = $Tween
onready var dashTimer : Timer = $DashTimer

signal using_pack

func _ready():
	pass


func _physics_process(delta):
	
	onGround = raycastBottom.is_colliding()
	if raycastRight.is_colliding() or raycastLeft.is_colliding():
		on_wall = true
	else:
		on_wall = false


	if state == MOVE:
		player_state_move()
		motion = move_and_slide(motion, up)
	elif state == HOLD:
		player_state_hold()
		motion = move_and_slide(motion, up)
	elif state == DASH:
		player_state_dash()
	
	#Calculate facing
	if motion.x > 0: facing = 1
	elif motion.x < 0: facing = -1
	else: facing = facing
	
#	direction = motion.normalized()
	
	#Animation
	body.scale.x = lerp(body.scale.x, 1, 0.5)
	body.scale.y = lerp(body.scale.y, 1, 0.5)
	



#Functions
#States
func player_state_move():
	if Input.is_action_pressed("right"):
		motion.x += accel
	elif Input.is_action_pressed("left"):
		motion.x -= accel
	else:
		motion.x = lerp(motion.x, 0, 0.1)
	
	#Jump section
	if !onGround:
		if coyote > 0:
			coyote -= 1
	else:
		coyote = coyoteMax
		dash_count = dash_count_max

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
	
	if !onGround:
		if (motion.y < 0) && (!Input.is_action_pressed(key_jump) && (!Input.is_action_pressed(key_pack))):
			motion.y *= 0.8
	if Input.is_action_pressed(key_pack):
		emit_signal("using_pack", Vector2(global_position.x, global_position.y + 8))
		if gas > 0:
			gas -= 1
			pack_power = lerp(pack_power, pack_power_max, 0.1)
		else:
			pack_power = lerp(pack_power, 0, 0.2)
	else:
		pack_power = lerp(pack_power, 0, 0.2)
		if onGround:
			gas = gas_max
	if raycastTop.is_colliding(): pack_power = 0
	gas_rate = gas / gas_max
	get_parent().get_node("PlayerUI").set_gas_rate(gas_rate)
	
	motion.y -= pack_power
	
	if !onGround : motion.y += gravity
	
	last_facing = facing
	
	motion.x = clamp(motion.x, -maxSpeed, maxSpeed)
	motion.y = clamp(motion.y, -maxFallSpeed, maxFallSpeed)
	
	#Switch statement
	if Input.is_action_just_pressed(key_hold) && on_wall: change_state(HOLD)
	if Input.is_action_just_pressed(key_dash) && dash_count > 0: 
#		freeze_frame(50)
		find_direction()
		dash_count -= 1
		motion *= Vector2.ZERO
		if direction == Vector2.ZERO: direction.x = last_facing
		change_state(DASH)

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
	if on_wall && direction.x != 0: 
		dashTween.stop_all()
		change_state(MOVE)
#	motion = lerp(motion, motion + direction * dash_power, 0.8)
#	motion = move_and_slide(motion, Vector2.ZERO)
	dashTween.interpolate_property(self, "motion", motion, motion + direction * dash_power, 0.15, Tween.TRANS_QUINT, Tween.EASE_OUT)
	dashTween.start()
	motion = move_and_slide(motion, Vector2.ZERO)
	
	pass

#Functions
func change_state(new_state):
	state = new_state

func squashAndStretch(xscale: float, yscale: float):
	body.scale.x = xscale
	body.scale.y = yscale

func find_direction():
	if Input.is_action_pressed("right"):
		direction.x = 1
	elif Input.is_action_pressed("left"):
		direction.x = -1
	else:
		direction.x = 0
#	direction.x = Input.is_action_pressed("right") or Input.is_action_pressed("left")
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"):
		direction.y = 1
	else:
		direction.y = 0
func freeze_frame(duration: float):
	OS.delay_msec(duration)
#Signals
func _on_DashTimer_timeout():
	motion *= 0.7
	find_direction()
	state = MOVE

func _on_Tween_tween_completed(object, key):
	motion *= 0.4
	find_direction()
	change_state(MOVE)
