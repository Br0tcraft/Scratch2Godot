extends Node2D
@export_group("Properties")
@export_range(-179, 180) var direction: float = 30.061443404791873
@export var stretch = Vector2i(100, 100)
@export var size = 100
var size_x = 1
@export_enum("all around", "left-right", "don't rotate") var rotation_type: String = "left-right"
@export_group("Variables")
