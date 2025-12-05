extends Control

@onready var top_bar := $TopBar
@onready var bot_bar := $BottomBar


const BAR_HEIGHT := 100.0
const SPEED := 3.0

var active : bool = false
var current_height = 0.0


func _ready():
	current_height = 0.0
	_apply_height()
	

func _process(delta):
	if active:
		var target_height = BAR_HEIGHT
		current_height = lerp(current_height, target_height, SPEED * delta)
		_apply_height()
	else:
		current_height = lerp(current_height, 0.0, 1.0 * delta)
		_apply_height()


func showbars():
	active = true


func hidebars():
	active = false
	
	
func _apply_height():
	top_bar.size.y = current_height
	bot_bar.size.y = current_height
	
