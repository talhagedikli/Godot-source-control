extends KinematicBody2D

var up : Vector2 = Vector2(0, -1)
var gravity : float = 6.00
var direction: Vector2 = Vector2.ZERO

var maxFallSpeed = 175
var maxSpeed = 150

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


var accel = 5
var decel = 8

var facing = 1
var last_facing = facing
var motion : Vector2 = Vector2()

enum playerStates {
	MOVE,
	HOLD,
	JUMP,
	DASH,
	FLY
}
var state = playerStates.MOVE

var key_hold = "z"
var key_pack = "alt"
var key_jump = "space"
var key_dash = "x"

onready var sprite = get_node("Pivot/Sprite")
onready var pivot = get_node("Pivot")
onready var body : Sprite = get_node("Pivot/Sprite")
onready var raycast_bottom : RayCast2D = $Collisions/BottomCollision
onready var raycast_top : RayCast2D = $Collisions/TopCollision
onready var raycast_left : RayCast2D = $Collisions/LeftCollision
onready var raycast_right : RayCast2D = $Collisions/RightCollision
onready var dashTween : Tween = $Tween

signal using_pack

func _ready():
	pass


func _physics_process(delta):
	
	onGround = raycast_bottom.is_colliding()
	if raycast_right.is_colliding() or raycast_left.is_colliding():
		on_wall = true
	else:
		on_wall = false

#	motion.y += gravity
#	if motion.y > maxFallSpeed:
#		motion.y = maxFallSpeed
	if state == playerStates.MOVE:
		player_state_move()
	elif state == playerStates.HOLD:
		player_state_hold()
	elif state == playerStates.DASH:
		player_state_dash(delta)
	
	motion = move_and_slide(motion, up)
	
	#Calculate facing
	if motion.x > 0: facing = 1
	elif motion.x < 0: facing = -1
	else: facing = facing
	
	direction = motion.normalized()
	
	#Animation
	body.scale.x = lerp(sprite.scale.x, 1, 0.5)
	body.scale.y = lerp(sprite.scale.y, 1, 0.5)
	


#Functions
func squashAndStretch(xscale : float, yscale : float):
	body.scale.x = xscale
	body.scale.y = yscale

#States
func player_state_move():
	set_direction()
	
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
			pack_power = lerp(pack_power, pack_power_max, 0.05)
		else:
			pack_power = lerp(pack_power, 0, 0.2)
	else:
		pack_power = lerp(pack_power, 0, 0.2)
		if onGround:
			gas = gas_max
	if raycast_top.is_colliding(): pack_power = 0
	gas_rate = gas / gas_max
	get_parent().get_node("PlayerUI").set_gas_rate(gas_rate)
	
	motion.y -= pack_power
	
	if !onGround : motion.y += gravity
	
	last_facing = facing
	
	motion.x = clamp(motion.x, -maxSpeed, maxSpeed)
	motion.y = clamp(motion.y, -maxFallSpeed, maxFallSpeed)
	
	#Switch statement
	if Input.is_action_just_pressed(key_hold) && on_wall: state = playerStates.HOLD
	if Input.is_action_just_pressed(key_dash): 
		state = playerStates.DASH
		$Timer.start()
func player_state_hold():
	if raycast_right.is_colliding(): facing = -1
	else: facing = 1
	motion.x = 0
	motion.y = lerp(motion.y, 0, 0.2)
	if Input.is_action_just_pressed(key_jump): 
		motion.x = jumpForce * facing * 0.7
		motion.y = -jumpForce * 0.8
		facing = last_facing
		state = playerStates.MOVE	
	if Input.is_action_just_released(key_hold): 
		facing = last_facing
		state = playerStates.MOVE		

func player_state_dash(delta):
	var move_to = direction * Vector2(jumpForce*5, jumpForce*5)
#	var dif = motion.distance_to(move_to)
##	dashTween.interpolate_property(self, "position", self.position, move_to, 0.2, Tween.TRANS_QUINT, Tween.EASE_IN)
##	if !dashTween.is_active(): dashTween.start()
#	if dif > 1: motion.move_toward(move_to, delta)
#	else: state = playerStates.MOVE

func set_direction():
	if Input.is_action_pressed("right"):
		direction.x = 1
	elif Input.is_action_pressed("left"):
		direction.x = -1
	else:
		direction.x = 0
	
	if Input.is_action_pressed("up"):
		direction.y = 1
	elif Input.is_action_pressed("down"):
		direction.y = -1
	else:
		direction.y = 0
func get_direction():
	return direction
	



#func _on_Tween_tween_completed(self, "Player/dashTween"):
#	state = playerStates.MOVE


func _on_Timer_timeout():
	state = playerStates.MOVE
