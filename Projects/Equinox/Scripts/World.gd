extends Node2D

onready var gameGui = get_node("GameGUI")


func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_pressed("r"):
		restart_game()
	if Input.is_action_just_pressed("esc"):
		quit_game()
	

func restart_game():
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()


