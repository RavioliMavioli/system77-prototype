extends Node

const SAVE_FILE = "user://Save/save.dat"

var game_data = {}

func _ready():
	
	load_data()
	
	if Global.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Global.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func load_data():
	var file
	if !FileAccess.file_exists(SAVE_FILE):
		if !DirAccess.dir_exists_absolute("user://Save"):
			var dir = DirAccess.open("user://")
			dir.make_dir("Save")
		save_data()

	file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	game_data = file.get_var()
	
	Global.fullscreen = game_data.fullscreen
	Global.vsync = game_data.vsync
	Global.show_fps = game_data.show_fps
	Global.chromatic = game_data.chromatic
	Global.enable_particle = game_data.enable_particle
	Global.continuable = game_data.continuable
	Global.current_level = game_data.current_level
	Global.player_global_position = game_data.player_global_position
	
	Global.max_lock = game_data.max_lock
	Global.fire_rate = game_data.fire_rate
	Global.fire_type = game_data.fire_type
	
	Global.obtained_double_jump = game_data.obtained_double_jump
	Global.obtained_dash = game_data.obtained_dash
	Global.obtained_hook = game_data.obtained_hook
	Global.obtained_specials = game_data.obtained_specials
	Global.items = game_data.items
	Global.high_score = game_data.high_score
	file.close()
	
func save_data():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	game_data = {
		"fullscreen" = Global.fullscreen,
		"vsync" = Global.vsync,
		"show_fps" = Global.show_fps,
		"chromatic" = Global.chromatic,
		"enable_particle" = Global.enable_particle,
		"continuable" = Global.continuable,
		"current_character" = Global.current_character,
		"max_lock" = Global.max_lock,
		"fire_type" = Global.fire_type,
		"fire_rate" = Global.fire_rate,
		"player_health" = Global.player_health,
		"current_level" = Global.current_level,
		"player_global_position" = Global.player_global_position,
		"obtained_double_jump" = Global.obtained_double_jump,
		"obtained_dash" = Global.obtained_dash,
		"obtained_hook" = Global.obtained_hook,
		"obtained_specials" = Global.obtained_specials,
		"items" = Global.items,
		"high_score" = Global.high_score
	
	}
	file.store_var(game_data)
	file.close()
