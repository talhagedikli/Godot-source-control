extends Node


func _ready():
	pass



func approach(start, end, shift):
	if start < end:
		return min(start + shift, end)
	else:
		return max(start - shift, end)
