extends Area2D
class_name PowerUp

signal collected(power_type: Type)

enum Type { BIG_BALL, MULTI_BALL, WIDE_PADDLE }

const FALL_SPEED := 180.0
const ICONS := {
	Type.BIG_BALL: preload("res://Assets/PowerUps/big_ball.png"),
	Type.MULTI_BALL: preload("res://Assets/PowerUps/multi_ball.png"),
	Type.WIDE_PADDLE: preload("res://Assets/PowerUps/wide_paddle.png"),
}
const COLORS := {
	Type.BIG_BALL: Color.ORANGE_RED,
	Type.MULTI_BALL: Color.MEDIUM_PURPLE,
	Type.WIDE_PADDLE: Color.LIME_GREEN,
}

var power_type := Type.BIG_BALL

@onready var visual: ColorRect = $Visual
@onready var icon: Sprite2D = $Icon

func _ready() -> void:
	visual.color = COLORS[power_type]
	icon.texture = ICONS[power_type]
	body_entered.connect(on_body_entered)

func _physics_process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 50.0:
		queue_free()

func on_body_entered(body: Node2D) -> void:
	if body is Paddle:
		collected.emit.call_deferred(power_type)
		queue_free()
