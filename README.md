# Regular Minesweeper
Mostly made in order to gain experience using the godot engine for future projects.
Particularly, one idea expands on Minesweeper so I thought it'd be good to have the mechanics of regular minesweeper down to use as a base.

# Compiling and Running
The most [recent release](https://github.com/Joseph-Orawiec/regular-minesweeper/releases/tag/v1.0.2) has a playable version in browser and an executable.


To edit in godot, import the project and select the folder.

# Classes Breakdown
## Cell.gd
This represents an arbitrary cell, containing methods and signals that have to do with a cell in the mine field.
It has an ID to mark what it contains and will handle all the logic that comes with clicking, flagging, chording, a zero open, and responding to when a win/lost state is achieved.

## camera_2d.gd
Handles the one camera's controls.
Panning and zooming on cursor.

## gui.gd
Handles starting the game and responding to user input to customize the mine field.

## mine_field.gd
This handles most of the game. Creatinng the minefield, receiving signals from cells and gui, and determining the win/lost condition. 
Handling chording and zero opens.

## assets.gd
This is a script that is autoloaded and acts like a global variable holder.
It contains the asset dictionary that's used when updating sprites as there are 2 different sets of textures the player can choose between.
It also helps contain all of the sprites so if a sprite is changed or added, only this file needs to be updated.
