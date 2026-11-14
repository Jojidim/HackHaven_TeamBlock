extends StaticBody2D
class_name Brick

signal destroyed(brick: Brick)

const SIZE := Vector2(36.0, 36.0)

var points := 10
var texture: Texture2D
var is_destroyed := false

@onready var visual: Sprite2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	visual.texture = texture
	visual.scale = SIZE / texture.get_size()
	collision_shape.shape.size = SIZE

func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	collision_shape.set_deferred("disabled", true)
	destroyed.emit(self)
	queue_free()
