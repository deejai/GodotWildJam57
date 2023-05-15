extends Node2D

@onready var start_game_button: Button = $StartGameButton

var room_scene: PackedScene = load("res://Game/Views/Room/Room.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_button_pressed():
	get_tree().change_scene_to_packed(room_scene)
