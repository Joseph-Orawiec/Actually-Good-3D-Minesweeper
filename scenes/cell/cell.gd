extends StaticBody2D

## Logic that decides what each individual cell should do

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)

var id # What kind of cell it is (number or mine)
var v # It's key within the cell dictionary
var is_pressed = false
var is_flagged = false
var is_chording = false

var pause = false

@onready var sprite_node = $Sprite2D # node reference to change the texture

# Called when the node enters the scene tree for the first time.
func _ready():
	# detecting mouse enter/exit, initializing signals
	var node = get_node(".")
	node.mouse_entered.connect(_on_mouse_entered)
	node.mouse_exited.connect(_on_mouse_exited)
	
	# Turn off polling initially
	set_process(false)
	
	# Initialize x and y
	v = Vector2(position.x / 50, position.y / 50)

func _process(delta):
	# Only care if it's not clicked yet
	if not is_pressed:
		# Only do click logic if it's not flagged as well
		if not is_flagged:
			if Input.is_action_pressed("m1"):
				# Change the texture to the right one
				sprite_node.set_texture(Assets.get_sprite(0))
			if Input.is_action_just_released("m1"): # Clicked
					# instead of making a is_started bool, ID can take it's place
					# if null, it's not started yet, emit signal to initialize
					# as the first click is never a mine
					if id == null:
						initialize.emit(v)
					# reveal cell
					click()
			
		# M2 flag cell
		if Input.is_action_just_pressed("m2"):
			if not is_flagged:
				flagged.emit(true) # emit signal to increment/decrement counter
				sprite_node.set_texture(Assets.get_sprite('flag'))
			else:
				flagged.emit(false)
				sprite_node.set_texture(Assets.get_sprite('unkown'))
			is_flagged = not is_flagged
	else:
		# check for chording logic
		if Input.is_action_pressed("chord"):
			chord_pressed.emit(v)
			is_chording = true
		if Input.is_action_just_released("chord"): # execute chord
			is_chording = false
			chord_released.emit(v)

# player click
func click(is_emitting:bool = true):
	# Whenever player clicks a mine or a cell is clicked indirectly via chording or 0 chain
	if not is_flagged:
		if not is_pressed:
			is_pressed = true
			sprite_node.set_texture(Assets.get_sprite(id))
			
			# prevent trying to zero chain recursively as previously implemented
			if id == 0 and is_emitting:
				zero_chain.emit(v)
			
			clicked.emit(id)
			
			if id == -1:
				set_process(false)

# special click function in order to not generate

# special flag function for when a game is won, flag all other mines
func won():
	pause = true
	if id == -1 and not is_flagged:
		flagged.emit(true)
		sprite_node.set_texture(Assets.get_sprite('flag'))
		
func lost():
	pause = true
	if id == -1 and not is_pressed:
		sprite_node.set_texture(Assets.get_sprite('mine_reveal'))
	
	if id != -1 and is_flagged:
		sprite_node.set_texture(Assets.get_sprite('flag_wrong'))

# this function is for when a neighboring cell is getting chorded, this cell needs to change asset
func chord_press():
	# Only do logic if not pressed and not flagged
	if not is_pressed and not is_flagged:
		# show about to be clicked cell sprite
		sprite_node.set_texture(Assets.get_sprite(0))

# execute chording logic when neighboring cell was chorded
func chord_release(flags_match_id):
	# Only do logic if not pressed and not flagged, same conditions as the initial chord_press
	if not is_pressed and not is_flagged:
		if flags_match_id:
			# and only if the requirements to chord were met
			click();
		else:
			# reset texture
			sprite_node.set_texture(Assets.get_sprite('unkown'))

# when a neighboring cell cancelled it's chord, reset sprite
func chord_cancel():
	if not is_pressed and not is_flagged:
		sprite_node.set_texture(Assets.get_sprite('unkown'))

# reset's the cell to initial state when created
func reset():
	id = null
	is_pressed = false
	is_flagged = false
	sprite_node.set_texture(Assets.get_sprite('unkown'))

# Signal stuff: mouse enter/leave
func _on_mouse_entered():
	# start polling if mouse is on cell 
	if not pause:
		set_process(true)

func _on_mouse_exited():
	if not pause:
		# Stop polling if mouse isn't on cell
		set_process(false)
		# only reset the sprite if it's not flagged and not already pressed 
		if not is_pressed and not is_flagged:
			sprite_node.set_texture(Assets.get_sprite('unkown'))
			
		# make sure to reset cells' sprites if stopped chording (was about to but moved mouse which means there was no release)
		if is_chording:
			is_chording = false
			chord_canceled.emit(v)
