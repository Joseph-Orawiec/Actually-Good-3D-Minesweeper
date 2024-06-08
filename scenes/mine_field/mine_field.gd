extends Node2D

## manages the mine field of the game

var open = 0
var count = 10 # mine count
var field_dict = {} # game board
var dimension = Vector2(9, 9) # size of the mine field
var node_dict = {} # node arr (parallel dictionary)
const adjacency_vectors = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1),
] # useful to loop through when chording

# Called when the node enters the scene tree for the first time.
func _ready():
	# connect signals
	$gui.start_game.connect(_on_init)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when first constructed
func _init():
	_on_init(Vector2(9, 9), 10)

# 
func _on_init(d, c):
	# update variables
	dimension = d
	count = c
	open = 0
	
	# clear out previous field
	for i in node_dict:
		node_dict[i].queue_free()
	node_dict = {}
	field_dict = {}
	
	var cell = preload("res://scenes/cell/cell.tscn")
	#initialize the game array full of 0's and setup cells
	for y in dimension.x:
		for x in dimension.y:
			field_dict[Vector2(x, y)] = 0
			# Setup cells
			node_dict[Vector2(x, y)] = cell.instantiate()
			var current_cell = node_dict[Vector2(x, y)]
			current_cell.initialize.connect(_on_initialize)
			current_cell.zero_chain.connect(_on_zero_chain)
			current_cell.chord_pressed.connect(_on_chord_pressed)
			current_cell.chord_released.connect(_on_chord_released)
			current_cell.chord_canceled.connect(_on_chord_canceled)
			current_cell.clicked.connect(_on_cell_clicked)
			current_cell.flagged.connect(_on_cell_flagged)
			current_cell.position.x = 50 * x
			current_cell.position.y = 50 * y
			add_child(current_cell)

# flag
func _on_cell_flagged(flagged):
	$gui.flag_update(flagged)

# regular click
func _on_cell_clicked(id):
	if (id == -1):
		lost()
	open += 1
	
	if (open == dimension.x * dimension.y - count):
		win()

# lose condition
func lost():
	$gui.end_game(false)
	for i in node_dict:
		node_dict[i].lost()
	

# Win condition
func win():
	$gui.end_game(true)
	for i in node_dict:
		node_dict[i].won()

# Initialize the mine field once i know which cell needs to be safe
func _on_initialize(v):
	# game setup
	var bombs = count # make a copy, need bomb count for win condition
	while bombs > 0:
		# Random mine
		var k = Vector2(randi_range(0, dimension.x - 1), randi_range(0, dimension.y - 1))
		while (k == v or field_dict[k] == -1): # repeat if placing on clicked cell OR on another mine
			k = Vector2(randi_range(0, dimension.x - 1), randi_range(0, dimension.y - 1))
		
		# decrease mines left to place and update the minefield
		bombs -= 1
		field_dict[k] = -1
		
		#Increment all adjacnt cells
		# Cell to potentially increment
		for u in adjacency_vectors:
			# Will create extra entries in the field dictionary but better than checking if it's a "legal" cell within the playfield
			# Current cell = keyCell + adjacency vector
			var current_cell = field_dict.get(k + u, 0) 
			if current_cell != -1: # Don't incremenet mine cells
				field_dict[k + u] = field_dict.get(k + u, 0) + 1
		
	# Now update all the nodes
	for i in node_dict:
		node_dict[i].id = field_dict[i]
		
	$gui.timer_start()

# when revealing a 0, reveal adjacent cells
func _on_zero_chain(v):
	for u in adjacency_vectors:
		var current_node = node_dict.get(v + u, null)
		
		if current_node != null: # if adjacent cell exists, open it.
			current_node.click()

# Change sprites of adjacent cells
func _on_chord_pressed(v):
	for u in adjacency_vectors:
		var current_node = node_dict.get(v + u, null)
		
		if current_node != null: # if adjacent cell exists, change sprite
			current_node.chord_press()
			
# Execute chord logic
func _on_chord_released(v):
	# first we need to make sure the amount of flags = cell number
	var sum_of_flags = 0
	for u in adjacency_vectors:
		var current_node = node_dict.get(v + u, null)
		if current_node != null: # if exists
			if current_node.is_flagged:
				sum_of_flags += 1
				
	# if so, reveal every adjacent cell
	if node_dict[v].id == sum_of_flags:
		for u in adjacency_vectors:
			var current_node = node_dict.get(v + u, null)
			if current_node != null: # if exists
				current_node.chord_release(true)
	else: # don't actually do anything instead
		for u in adjacency_vectors:
			var current_node = node_dict.get(v + u, null)
			if current_node != null: # if exists
				current_node.chord_release(false)
			
# reset the sprites of adjacent cell if mouse moved off
func _on_chord_canceled(v):
	for u in adjacency_vectors:
		var current_node = node_dict.get(v + u, null)
		if current_node != null: # if exists
			current_node.chord_cancel()
