extends CanvasLayer

# nodes
@onready var x = $settings_panel/field_settings_holder/x_edit
@onready var y = $settings_panel/field_settings_holder/y_edit
@onready var bomb = $settings_panel/field_settings_holder/bomb_edit

var previous_coordinates
var is_dragging
var timer = 0

signal start_game(x, y, bomb_count)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# Connecting bunch of signals
	# connect board size and bomb count to verify user input
	x.text_changed.connect(_on_text_changed.bind(x))
	y.text_changed.connect(_on_text_changed.bind(y))
	bomb.text_changed.connect(_on_text_changed.bind(bomb))
	
	# connect in case it's left blank
	x.focus_exited.connect(_on_focus_exited.bind(x))
	y.focus_exited.connect(_on_focus_exited.bind(y))
	bomb.focus_exited.connect(_on_focus_exited.bind(bomb))
	
	# difficulty connects
	$settings_panel/diff_buttons/easy.pressed.connect(_on_set_easy)
	$settings_panel/diff_buttons/medium.pressed.connect(_on_set_med)
	$settings_panel/diff_buttons/expert.pressed.connect(_on_set_exp)
	
	# alternately close
	$settings.pressed.connect(_on_settings_button_pressed)
	
	# close button
	$settings_panel/close_holder/x_button.pressed.connect(_on_x_button_pressed)
	
	#start game 
	$start_game.pressed.connect(_on_start_game_pressed)
	set_process(false)

func _process(delta):
	timer += delta
	$timer.text = str(round(timer))

func _on_focus_exited(n):
	# if left blank, set a placeholder value
	if (n.text.length() == 0):
		n.text = "1"

func _on_text_changed(n):
	# verify user input (no letters)
	if (n.text.length() != 0):
		# at most, there will only ever be one non number chjaracter
		for i in range(n.text.length()):
			var char = n.text[i]
			if (char not in "0123456789"):
				n.text = n.text.get_slice(char, 0) + n.text.get_slice(char, 1)
				break
	
	# make sure bomb count is a possible amouunt
	var x = int(x.text)
	var y = int(y.text)
	var count = int(bomb.text)
	
	if (count >= x * y):
		bomb.text = str(x * y - 1)
	
	pass # Replace with function body.

# difficulty set
func _on_set_easy():
	x.text = '9'
	y.text = '9'
	bomb.text = '10'
	
func _on_set_med():
	x.text = '16'
	y.text = '16'
	bomb.text = '40'
	
func _on_set_exp():
	x.text = '30'
	y.text = '16'
	bomb.text = '99'

# open and closing panel
func _on_settings_button_pressed():
	$settings_panel.visible = not $settings_panel.visible

func _on_x_button_pressed():
	$settings_panel.visible = false
	
func _on_start_game_pressed():
	if ($settings_panel/skin_buttons/dot.button_pressed):
		Assets.skin = Assets.UserSkin.DOTS
	else:
		Assets.skin = Assets.UserSkin.NUMBERS
	
	$start_game.texture_normal = preload('res://assets/sprites/ui/game_on.png')
	$mine_count.text = bomb.text
	
	# reset timer, start game
	set_process(false)
	timer = 0
	$timer.text = '0'
	start_game.emit(Vector2(int(x.text), int(y.text)), int(bomb.text))
	

# updating gui
func flag_update(is_flag):
	if is_flag:
		$mine_count.text = str(int($mine_count.text) - 1)
		
		if int($mine_count.text) < 0:
			$mine_count.position = Vector2(14, -106)
		
	else:
		$mine_count.text = str(int($mine_count.text) + 1)
		if int($mine_count.text) >= 0:
			$mine_count.position = Vector2(14, -131)
		

func timer_start():
	set_process(true)

# draggable window
func _input(event):
	# little bit of code from camera_2d.gd and 
	# https://www.youtube.com/watch?v=__8MkpJjMGY
	if event.is_action("m1"):
		# detect if cursor is on box
		var event_pos = event.global_position
		var bar_pos = $settings_panel.get_global_position()
		var bar_size = $settings_panel.get_size()
		var target_rect = Rect2(bar_pos.x, bar_pos.y, bar_size.x, bar_size.y)
		
		if target_rect.has_point(event_pos):
			# record starting coordinates and start dragging
			if not is_dragging and event.pressed:
				is_dragging = true
				previous_coordinates = event_pos
			# Stop dragging if the button is released.
			if is_dragging and not event.pressed:
				is_dragging = false

		# panning
	if event is InputEventMouseMotion and is_dragging:
		$settings_panel.position += (event.get_global_position() - previous_coordinates)
		previous_coordinates = event.get_global_position()
		

func end_game(is_won):
	set_process(false)
	$timer.text = str(snapped(timer, .001))
	if is_won:
		$start_game.texture_normal = preload('res://assets/sprites/ui/game_won.png')
	else:
		$start_game.texture_normal = preload("res://assets/sprites/ui/game_loss.png")
