extends Node

########## INIT DATA ########## 

var just_started = 1

var test = 1
var fullscreen = 0
var vsync = 1
var show_fps = 0
var chromatic = 1
var enable_particle = 1

var continuable = 1

var current_level: int  = 1


########## PLAYER ########## 

var player_health: int = 100
var characters: Array = ["arch", "lfs"]
var current_character:int = 0
var player_global_position: Vector2 = Vector2(0,0)
var player_current_global_position: Vector2 = Vector2(0,0)
var score: int
var high_score: int

var max_lock: int = 2
var fire_type: int = 1
var fire_rate: int = 8000

var items: Array = []

var shoot_L_ammo: int
var shoot_R_ammo: int
var max_ammo:int = 100
var special_q: bool

var obtained_double_jump: bool = false
var obtained_dash: bool = false
var obtained_hook: bool = false
var obtained_specials: bool = false

########## BOSS ########## 

var boss_health: int

########## LOCK SYSTEM ##########

var current_locked: int = 0
var lock_queue: Array
var local_target_querry: Array

########## UI ########## 

var camera_node: Camera2D
var is_paused: bool = false
