extends CanvasLayer

onready var TweenNode = get_node("GasRate/Tween")

onready var gasRate : Node = $GasRate
var gas_rate : float = 0.00 setget set_gas_rate, get_gas_rate
var gas_rate_a = 1 setget set_gas_rate_a, get_gas_rate_a

func _physics_process(delta):
	#Set gas rate hud
#	if gas_rate < 0.4: 
#		gas_rate_a = TweenNode.interpolate_method(self, "set_gas_rate_a", 0, 1, 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
#		TweenNode.start()
#	else:
#		TweenNode.stop(self)
#		gas_rate_a = 1
	gasRate.rect_scale.x = lerp(gasRate.rect_scale.x, gas_rate, 0.1) + 0.0001
#	gasRate.rect_clip_content.color.set_frame_color(1, 1, 1, gas_rate_a)

#Functions
func set_gas_rate(value : float):
	gas_rate = value

func get_gas_rate():
	return gas_rate

func set_gas_rate_a(value):
	gas_rate_a = value

func get_gas_rate_a():
	return gas_rate_a
