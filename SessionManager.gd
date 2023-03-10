extends Node

const max_blocks: int = 3

signal about_to_cross_line
signal reset_blocks_left_to(to)

onready var player: Node2D = get_node("../Player")
onready var root = get_parent()

var must_get_to_height: float = 128.0
var score: int = 0

func _ready():
	emit_signal("reset_blocks_left_to", max_blocks)

func _process(_delta):
	if player.global_position.y <= must_get_to_height:
		emit_signal("about_to_cross_line")
		must_get_to_height -= 128.0
		$Energize.play()
		emit_signal("reset_blocks_left_to", max_blocks)
		for b in root.get_node("Chunks").get_children():
			b.freeze()
		root.get_node("Player").lives = 3
# warning-ignore:narrowing_conversion
	score = max(score, -int(player.global_position.y - 223.0))
	
	# this is bad but this game is due in 40 minutes
	root.get_node("UI/Score").text = str(score)
	root.get_node("NextLine").global_position.y = must_get_to_height

	if Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		var _err = get_tree().reload_current_scene()
		
