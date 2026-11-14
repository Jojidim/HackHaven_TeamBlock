extends CharacterBody2D
class_name Ball

signal fell_off(ball: Ball)

const BIG_BALL_SCALE := 2.0
const BIG_BALL_BRICK_LIMIT := 3
const MAX_BOUNCE_ANGLE := PI / 3.0
const MIN_VERTICAL_SHARE := 0.25

@export var speed := 450.0

var is_launched := false
var bricks_left_to_smash := 0

# --- Movement ---
func launch(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
	is_launched = true

func _physics_process(delta: float) -> void:
	if not is_launched:
		return
	var collision := move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision)
	if global_position.y > get_viewport_rect().size.y + 50.0:
		fell_off.emit(self)

# --- Collisions ---
func handle_collision(collision: KinematicCollision2D) -> void:
	var hit_object := collision.get_collider()
	if hit_object is Paddle:
		bounce_off_paddle(hit_object)
	elif hit_object is Brick:
		hit_brick(hit_object, collision.get_normal())
	else:
		velocity = velocity.bounce(collision.get_normal())
	keep_ball_moving_upward_or_downward()

func bounce_off_paddle(paddle: Paddle) -> void:
	var hit_position := (global_position.x - paddle.global_position.x) / (paddle.width / 2.0)
	var angle := clampf(hit_position, -1.0, 1.0) * MAX_BOUNCE_ANGLE
	velocity = Vector2(sin(angle), -cos(angle)) * speed

func hit_brick(brick: Brick, normal: Vector2) -> void:
	brick.destroy()
	if bricks_left_to_smash > 0:
		bricks_left_to_smash -= 1
		if bricks_left_to_smash == 0:
			scale = Vector2.ONE
	else:
		velocity = velocity.bounce(normal)

func keep_ball_moving_upward_or_downward() -> void:
	var min_vertical_speed := speed * MIN_VERTICAL_SHARE
	if absf(velocity.y) < min_vertical_speed:
		var vertical_direction := -1.0 if velocity.y <= 0.0 else 1.0
		velocity.y = min_vertical_speed * vertical_direction
		velocity = velocity.normalized() * speed

# --- Power-ups ---
func activate_big_ball() -> void:
	bricks_left_to_smash = BIG_BALL_BRICK_LIMIT
	scale = Vector2.ONE * BIG_BALL_SCALE
