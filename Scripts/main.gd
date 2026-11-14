extends Node2D

const BALL_SCENE := preload("res://Scenes/ball.tscn")
const BRICK_SCENE := preload("res://Scenes/brick.tscn")
const POWER_UP_SCENE := preload("res://Scenes/powerup.tscn")

const STARTING_LIVES := 3
const BRICK_COLUMNS := 22
const BRICK_ROWS := 6
const BRICK_GAP := 2.0
const BRICK_AREA_TOP := 90.0
const GRASS_TEXTURE := preload("res://Assets/Tiles/tile_0000.png")
const DIRT_TEXTURE := preload("res://Assets/Tiles/tile_0006.png")
const POINTS_PER_ROW := 10

const BASE_BALL_SPEED := 450.0
const BALL_SPEED_GAIN_PER_LEVEL := 0.05
const MAX_BALL_SPEED := 900.0
const BALL_HEIGHT_ABOVE_PADDLE := 20.0

const POWER_UP_DROP_CHANCE := 0.2
const EXTRA_BALL_COUNT := 3

var lives := 0
var score := 0
var level := 1
var bricks_left := 0
var balls: Array[Ball] = []
var is_waiting_to_launch := false
var is_game_over := false

@onready var paddle: Paddle = $Paddle
@onready var bricks_holder: Node2D = $Bricks
@onready var balls_holder: Node2D = $Balls
@onready var power_ups_holder: Node2D = $PowerUps
@onready var hud: HUD = $HUD

func _ready() -> void:
	start_new_game()

func _process(_delta: float) -> void:
	if is_waiting_to_launch:
		balls[0].position = paddle.position + Vector2(0.0, -BALL_HEIGHT_ABOVE_PADDLE)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	if is_game_over:
		start_new_game()
	elif is_waiting_to_launch:
		launch_ball()

#flow of the game
func start_new_game() -> void:
	lives = STARTING_LIVES
	score = 0
	level = 1
	is_game_over = false
	paddle.reset()
	remove_all_children(power_ups_holder)
	remove_all_balls()
	build_bricks()
	spawn_ball_on_paddle()
	hud.update_score(score)
	hud.update_level(level)
	hud.update_lives(lives)

func start_next_level() -> void:
	level += 1
	remove_all_children(power_ups_holder)
	remove_all_balls()
	build_bricks()
	spawn_ball_on_paddle()
	hud.update_level(level)

func lose_life() -> void:
	lives -= 1
	hud.update_lives(lives)
	paddle.reset()
	if lives > 0:
		spawn_ball_on_paddle()
	else:
		end_game()

func end_game() -> void:
	is_game_over = true
	remove_all_children(power_ups_holder)
	hud.show_message("GAME OVER\nScore: %d\nPress SPACE to play again" % score)

# --- Balls ---
func spawn_ball(spawn_position: Vector2) -> Ball:
	var ball: Ball = BALL_SCENE.instantiate()
	ball.speed = current_ball_speed()
	ball.position = spawn_position
	ball.fell_off.connect(on_ball_fell_off)
	balls_holder.add_child(ball)
	balls.append(ball)
	return ball

func spawn_ball_on_paddle() -> void:
	spawn_ball(paddle.position + Vector2(0.0, -BALL_HEIGHT_ABOVE_PADDLE))
	is_waiting_to_launch = true
	hud.show_message("Press SPACE to launch")

func launch_ball() -> void:
	balls[0].launch(Vector2(randf_range(-0.5, 0.5), -1.0))
	is_waiting_to_launch = false
	hud.hide_message()

func current_ball_speed() -> float:
	var speed := BASE_BALL_SPEED * (1.0 + BALL_SPEED_GAIN_PER_LEVEL * (level - 1))
	return minf(speed, MAX_BALL_SPEED)

func remove_all_balls() -> void:
	remove_all_children(balls_holder)
	balls.clear()
	is_waiting_to_launch = false

func on_ball_fell_off(ball: Ball) -> void:
	balls.erase(ball)
	ball.queue_free()
	if balls.is_empty():
		lose_life()

#the bricks
func build_bricks() -> void:
	remove_all_children(bricks_holder)
	var grid_width := BRICK_COLUMNS * Brick.SIZE.x + (BRICK_COLUMNS - 1) * BRICK_GAP
	var left_edge := (get_viewport_rect().size.x - grid_width) / 2.0
	for row in BRICK_ROWS:
		for column in BRICK_COLUMNS:
			var brick: Brick = BRICK_SCENE.instantiate()
			brick.position = Vector2(
				left_edge + Brick.SIZE.x / 2.0 + column * (Brick.SIZE.x + BRICK_GAP),
				BRICK_AREA_TOP + Brick.SIZE.y / 2.0 + row * (Brick.SIZE.y + BRICK_GAP)
			)
			brick.texture = GRASS_TEXTURE if row == 0 else DIRT_TEXTURE
			brick.points = (BRICK_ROWS - row) * POINTS_PER_ROW
			brick.destroyed.connect(on_brick_destroyed)
			bricks_holder.add_child(brick)
	bricks_left = BRICK_ROWS * BRICK_COLUMNS

func on_brick_destroyed(brick: Brick) -> void:
	score += brick.points
	bricks_left -= 1
	hud.update_score(score)
	drop_power_up_sometimes(brick.position)
	if bricks_left == 0:
		start_next_level()

#power ups
func drop_power_up_sometimes(drop_position: Vector2) -> void:
	if randf() > POWER_UP_DROP_CHANCE:
		return
	var power_up: PowerUp = POWER_UP_SCENE.instantiate()
	power_up.power_type = PowerUp.Type.values().pick_random()
	power_up.position = drop_position
	power_up.collected.connect(on_power_up_collected)
	power_ups_holder.add_child(power_up)

func on_power_up_collected(power_type: PowerUp.Type) -> void:
	if is_game_over:
		return
	match power_type:
		PowerUp.Type.BIG_BALL:
			for ball in balls:
				ball.activate_big_ball()
		PowerUp.Type.MULTI_BALL:
			spawn_extra_balls()
		PowerUp.Type.WIDE_PADDLE:
			paddle.widen()

func spawn_extra_balls() -> void:
	var source_position := balls[0].position
	for i in EXTRA_BALL_COUNT:
		var ball := spawn_ball(source_position)
		ball.launch(Vector2.UP.rotated(randf_range(-0.8, 0.8)))























func remove_all_children(holder: Node) -> void:
	for child in holder.get_children():
		child.queue_free()
