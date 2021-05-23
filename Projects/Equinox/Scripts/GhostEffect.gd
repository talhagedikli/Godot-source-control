extends Sprite


func _ready():
	pass

func _physics_process(delta):
	modulate.a -= 0.03
	if modulate.a <= 0:
		queue_free()
