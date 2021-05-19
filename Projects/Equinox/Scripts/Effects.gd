extends Node2D

export var gas_effect: PackedScene


func create_gas_effect(pack_position: Vector2):
	var temp = gas_effect.instance()
	add_child(temp)
	temp.position = pack_position
	


func _on_Player_using_pack(pack_position: Vector2):
	create_gas_effect(pack_position)
