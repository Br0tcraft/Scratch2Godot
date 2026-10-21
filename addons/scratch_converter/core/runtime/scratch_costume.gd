class_name ScratchCostume
extends Resource

@export var name: String = ""
@export var texture: Texture2D = null
@export var rotation_center: Vector2 = Vector2.ZERO
@export var bitmap_resolution: float = 1.0
@export var hitbox_polygon: PackedVector2Array = PackedVector2Array()
@export var hitbox_polygons: Array[PackedVector2Array] = []