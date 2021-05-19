extends Position2D

var grid_size = Vector2()
var grid_position = Vector2()
var view = get_viewport_rect()

onready var parent = get_parent()

func _ready():
	view = get_viewport_rect()
	grid_size = view.size
	set_as_toplevel(true)
	update_grid_position()

func _physics_process(delta):
	update_grid_position()


func update_grid_position():
	var x = round((parent.position.x - grid_size.x/2) / grid_size.x) 
	var y = round((parent.position.y - grid_size.y/2) / grid_size.y)
	var new_grid_position = Vector2(x, y)
	if grid_position == new_grid_position:
		return
	grid_position = new_grid_position
	position = grid_position * grid_size
