extends CanvasLayer
class_name HUD

@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var lives_label: Label = $LivesLabel
@onready var message_label: Label = $MessageLabel

func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score

func update_level(level: int) -> void:
	level_label.text = "Level %d" % level

func update_lives(lives: int) -> void:
	lives_label.text = "Lives: %d" % lives

func show_message(text: String) -> void:
	message_label.text = text
	message_label.show()

func hide_message() -> void:
	message_label.hide()
