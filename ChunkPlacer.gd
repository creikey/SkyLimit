extends Node2D

export (NodePath) var place_onto_path

const rotation_amount: float = 180.0 # in degrees per second
const keep_upcoming_chunks: int = 3

onready var place_onto: Node = get_node(place_onto_path)
var next_chunk: Chunk = null

const chunks: Array = [
	preload("res://chunks/DirtCross.tscn"),
	preload("res://chunks/DirtIsland.tscn"),
	preload("res://chunks/DirtLog.tscn"),
]

var upcoming_chunks: Array = []

func _ready():
	randomize()

var last_mouse := Vector2()

func _process(delta):
	while upcoming_chunks.size() < keep_upcoming_chunks:
		upcoming_chunks.append(randi()%chunks.size())
	
	if next_chunk == null:
		next_chunk = chunks[upcoming_chunks.pop_front()].instance()
		add_child(next_chunk)
#	print(get_local_mouse_position())
	next_chunk.global_position = (last_mouse - get_viewport().canvas_transform.get_origin()*2.0)/2.0
	next_chunk.rotation += delta*deg2rad(rotation_amount)*(Input.get_action_strength("rotate_chunk_right") - Input.get_action_strength("rotate_chunk_left"))

	if Input.is_action_just_pressed("place_chunk"):
		remove_child(next_chunk)
		place_onto.add_child(next_chunk)
		next_chunk.place()
		next_chunk = null

#func _unhandled_input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_WHEEL_UP:
#			next_chunk.rotation += deg2rad(rotation_amount)

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse = event.position
