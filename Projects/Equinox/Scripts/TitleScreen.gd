extends Control


func _ready():
	pass


func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/World.tscn")


func _on_QuitButton_pressed():
	pass
