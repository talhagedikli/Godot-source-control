extends CanvasLayer


var gas_rate : float = 0.00 setget set_gas_rate, get_gas_rate
var gas_rate_a = 1 setget set_gas_rate_a, get_gas_rate_a
var counter: float = 0

onready var TweenNode = get_node("GasRate/Tween")
onready var gasRate : Node = $GasRate

func _ready():
	pass

func _physics_process(delta):
	#Set gas rate hud
#	if gas_rate < 0.6: 
#		TweenNode.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
#		TweenNode.start()
#	else:
#		TweenNode.stop(self)
#		gasRate.modulate.a = 1
	if gas_rate < 0.4:
		counter += 1
		gasRate.modulate.a = sin(counter/2)
	else:
		gasRate.modulate.a = 1
		counter = 0
	
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
