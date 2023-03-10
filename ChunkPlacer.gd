extends Node2D

signal up_next_changed(new_up_next)

export (NodePath) var place_onto_path

const rotation_amount: float = 180.0 # in degrees per second
const preview_chunks: int = 3

onready var place_onto: Node = get_node(place_onto_path)
var next_chunk: Chunk = null
var locked: bool = false


# first element is relative probability
const chunks: Array = [
	[1.0, preload("res://chunks/DirtHump.tscn")],
	[1.0, preload("res://chunks/DirtIsland.tscn")],
	[1.0, preload("res://chunks/DirtLog.tscn")],
	[0.7, preload("res://chunks/DirtLadder.tscn")],
	[0.5, preload("res://chunks/DirtBigIsland.tscn")],
	[0.4, preload("res://chunks/DirtBracket.tscn")],
	[0.5, preload("res://chunks/Ladder.tscn")],
]

var upcoming_chunks: Array = [
#	preload("res://chunks/DirtLog.tscn"),
#	preload("res://chunks/DirtLog.tscn"),
#	preload("res://chunks/Ladder.tscn")
]

func chunks_left() -> int: # ui
	var to_return: int = upcoming_chunks.size()
	if next_chunk != null:
		to_return += 1
	return to_return


func get_new_random_chunk() -> PackedScene:
	var total: float = 0.0
	for c in chunks:
		total += c[0]
	var got: float = rand_range(0.0, total)
	for c in chunks:
		if got < c[0]:
			return c[1]
		got -= c[0]
	assert(false)
	return null


func _ready():
	randomize()

var last_mouse := Vector2()

func updated_upcoming_chunks():
	var chunks_to_preview = []
	for i in range(0, upcoming_chunks.size()):
		if i >= preview_chunks:
			break
		chunks_to_preview.append(upcoming_chunks[i])
	emit_signal("up_next_changed", chunks_to_preview)

func _process(delta):
	if next_chunk == null and upcoming_chunks.size() > 0:
		next_chunk = upcoming_chunks.pop_front().instance()
		updated_upcoming_chunks()
		add_child(next_chunk)
#	print(get_local_mouse_position())
	if next_chunk != null:
		if not locked:
			next_chunk.global_position = (last_mouse - get_viewport().canvas_transform.get_origin()*2.0)/2.0
		next_chunk.rotation += delta*deg2rad(rotation_amount)*Input.get_action_strength("rotate_chunk_right")
		var overlapping: bool = next_chunk.overlapping()
		if overlapping:
			next_chunk.modulate = Color(1, 0, 0)
		else:
			next_chunk.modulate = Color(1, 1, 1)

		if Input.is_action_just_pressed("place_chunk"):
			if overlapping:
				$CantPlace.pitch_scale = rand_range(0.9, 1.1)
				$CantPlace.play()
			else:
				locked = true
		
		if locked and Input.is_action_just_released("place_chunk"):
			locked = false
			if overlapping:
				$CantPlace.pitch_scale = rand_range(0.9, 1.1)
				$CantPlace.play()
			else:
				place_current_chunk()

func place_current_chunk():
	locked = false
	$Place.play()
	remove_child(next_chunk)
	place_onto.add_child(next_chunk)
	next_chunk.place()
	next_chunk = null

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse = event.position

func _on_SessionManager_reset_blocks_left_to(to):
	var new_size: int = upcoming_chunks.size() + to
	while upcoming_chunks.size() < new_size:
		upcoming_chunks.append(get_new_random_chunk())
		updated_upcoming_chunks()

func _on_Player_collected_pickup():
	upcoming_chunks.append(get_new_random_chunk())
	updated_upcoming_chunks()

func _on_SessionManager_about_to_cross_line():
	if locked:
		place_current_chunk()
