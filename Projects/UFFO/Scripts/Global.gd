extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var input_direction : Vector2 = Vector2(0, 0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()
		
		
	

func check_input():
	if (Input.is_action_pressed("ui_right")):
		input_direction.x = 1
	elif (Input.is_action_pressed("ui_left")):
		input_direction.x = -1
	else:
		input_direction.x = 0
	
	if (Input.is_action_pressed("ui_down")):
		input_direction.y = 1
	elif (Input.is_action_pressed("ui_up")):
		input_direction.y = -1
	else:
		input_direction.y = 0
