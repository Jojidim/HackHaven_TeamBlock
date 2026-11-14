extends CharacterBody2D
class_name Paddle

const HEIGHT := 20.0
const DEFAULT_WIDTH := 140.0
const WIDE_WIDTH := 220.0
const WIDE_DURATION := 10.0

@export var speed := 600.0

var width := DEFAULT_WIDTH

@onready var visual: ColorRect = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var wide_timer: Timer = $WideTimer

func _ready() -> void:
	wide_timer.timeout.connect(set_width.bind(DEFAULT_WIDTH))

#movement
func _physics_process(_delta: float) -> void:
	var screen_width := get_viewport_rect().size.x
	velocity = Vector2(Input.get_axis("left", "right") * speed, 0.0)
	move_and_slide()
	position.x = clampf(position.x, width / 2.0, screen_width - width / 2.0)

#size
func set_width(new_width: float) -> void:
	width = new_width
	visual.scale.x = width / DEFAULT_WIDTH
	collision_shape.shape.size = Vector2(width, HEIGHT)

func widen() -> void:
	set_width(WIDE_WIDTH)
	wide_timer.start(WIDE_DURATION)

func reset() -> void:
	wide_timer.stop()
	set_width(DEFAULT_WIDTH)
	position.x = get_viewport_rect().size.x / 2.0
