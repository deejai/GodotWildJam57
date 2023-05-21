extends CanvasLayer

class_name PlayerHUD

@onready var pickup_label: Label = $PickupLabel

var show_help: bool = true

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ToggleHelp"):
		show_help = !show_help
		$HelpText.visible = show_help
		$HelpTextHint.visible = !show_help
