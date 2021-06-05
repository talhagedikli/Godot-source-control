extends CanvasLayer

const RED = Color(1, 0, 0, 1)

var gas_rate : float = 0.00 setget set_gas_rate, get_gas_rate
var gas_rate_a = 0.8 setget set_gas_rate_a, get_gas_rate_a
var counter: float = 0

onready var gasTween = get_node("GasRate/Tween")
onready var gasRate : Node = $GasRate

onready var dashCounter = get_node("DashCounter")
var dash_count = 0 setget set_dash_count
var dash_count_max = 3
const cell_size = 16

func _ready():
	pass

func _physics_process(delta):
	# Player's gas rate UI
	gasRate.modulate.a = sin(OS.get_system_time_msecs()/25) if (gas_rate < 0.4) else 0.8
	gasRate.rect_scale.x = lerp(gasRate.rect_scale.x, gas_rate, 0.1) + 0.0001
	
	# Players dash count UI
	if dash_count < 2:
		dashCounter.modulate.a = sin(OS.get_system_time_msecs()/25)
		dashCounter.modulate.blend(RED)
	elif dash_count < 3:
		dashCounter.modulate.a = sin(OS.get_system_time_msecs()/50)
	else: 
		dashCounter.modulate.a = GlobalFunc.approach(dashCounter.modulate.a, 0.8, 0.2)
	dashCounter.rect_size.x = GlobalFunc.approach(dashCounter.rect_size.x, cell_size * dash_count, 8)
	
	


#Functions
func set_gas_rate(value : float):
	gas_rate = value

func get_gas_rate():
	return gas_rate

func set_gas_rate_a(value):
	gas_rate_a = value

func get_gas_rate_a():
	return gas_rate_a

func set_dash_count(value):
	dash_count = value

func _on_Player_dahsed():
	dashCounter.rect_size.x = cell_size * dash_count
