extends Node2D

onready var ray = get_node("/root/Camera/RayCast")
export var mouse_sensitivity = .3
export var camera_x_rotation = 0

func _ready():
	$Sprite.position = Vector2(400, 300)
