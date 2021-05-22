extends Node2D

onready var gameGui = get_node("GameGUI")


func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_pressed("r"):
		restart_game()
	

func restart_game():
	get_tree().reload_current_scene()

func approach(start, end, shift):
	if start < end:
		return min(start + shift, end)
	else:
		return max(start - shift, end)
