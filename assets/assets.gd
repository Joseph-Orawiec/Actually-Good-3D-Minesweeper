extends Node

enum UserSkin {DOTS, NUMBERS}

var skin = UserSkin.DOTS

var dot_dict = { # dictionary of sprites
	0: load("res://assets/sprites/0.png"),
	1: load('res://assets/sprites/dots/values/1.png'),
	2: load("res://assets/sprites/dots/values/2.png"),
	3: load("res://assets/sprites/dots/values/3.png"),
	4: load("res://assets/sprites/dots/values/4.png"),
	5: load("res://assets/sprites/dots/values/5.png"),
	6: load("res://assets/sprites/dots/values/6.png"),
	7: load("res://assets/sprites/dots/values/7.png"),
	8: load("res://assets/sprites/dots/values/8.png"),
	-1: load("res://assets/sprites/dots/mine_clicked.png"),
	'flag': load("res://assets/sprites/dots/flag.png"),
	'flag_wrong': load("res://assets/sprites/dots/flagged_wrong.png"),
	'mine_reveal': load('res://assets/sprites/dots/mine_reveal.png'),
	'unkown': load('res://assets/sprites/unkown.png'),
}

var number_dict = { # dictionary of sprites
	0: load("res://assets/sprites/0.png"),
	1: load('res://assets/sprites/numbers/values/1.png'),
	2: load("res://assets/sprites/numbers/values/2.png"),
	3: load("res://assets/sprites/numbers/values/3.png"),
	4: load("res://assets/sprites/numbers/values/4.png"),
	5: load("res://assets/sprites/numbers/values/5.png"),
	6: load("res://assets/sprites/numbers/values/6.png"),
	7: load("res://assets/sprites/numbers/values/7.png"),
	8: load("res://assets/sprites/numbers/values/8.png"),
	-1: load("res://assets/sprites/numbers/mine_clicked.png"),
	'flag': load("res://assets/sprites/numbers/flag.png"),
	'flag_wrong': load("res://assets/sprites/numbers/flagged_wrong.png"),
	'mine_reveal': load('res://assets/sprites/numbers/mine_reveal.png'),
	'unkown': load('res://assets/sprites/unkown.png'),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_sprite(key):
	match skin:
		UserSkin.DOTS:
			return dot_dict[key]
		UserSkin.NUMBERS:
			return number_dict[key]
