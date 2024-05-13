extends Node2D

var button:String
var slide = false
var menu_position_offset: Vector2 
var sub_menu_position_offset: Vector2 
var opacity: float = 1.0

func play_sound(click_or_hover):
	match click_or_hover:
		"hover":
			$Hover.play()
		"click":
			$Click.play()
			
func _ready():
	$MenuText/MarginContainer/VBoxContainer/Continue.disabled = Global.continuable
	$Loading2.mouse_filter = $Loading2.MOUSE_FILTER_IGNORE
	$Options/MarginContainer/VBoxContainer/FullScreen.button_pressed = Global.fullscreen
	$Options/MarginContainer/VBoxContainer/Vsync.button_pressed = Global.vsync
	$Options/MarginContainer/VBoxContainer/VsyncWarning.visible = abs(Global.vsync - 1)
	$Options/MarginContainer/VBoxContainer/ShowFPS.button_pressed = Global.show_fps
	$Options/MarginContainer/VBoxContainer/CA.button_pressed = Global.chromatic
	$Options/MarginContainer/VBoxContainer/EnableParticle.button_pressed = Global.enable_particle

	button = "NewGame"
	$MenuText.visible = true
	$NewGame.visible = false
	$Options.visible = false
	$Credit.visible = false
	$QuitConfirm.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$MenuText/Title/DashAnimation.play("dash")
	$Loading2.visible = true
	$StartScreen.visible = true
	
	if Global.just_started == 0:
		$StartScreen.queue_free()
		$BG.init()
		$AnimationPlayer.play("loading1")
	
	
	$MenuText/MarginContainer/VBoxContainer/Continue.hide()
	
func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var button_pressed = get_node(button)
	
	menu(button, mouse_pos, button_pressed)
	
	if Input.is_action_just_pressed("ESC"):
		if !slide:
			if quit_confirm():
				get_tree().quit()
			$QuitConfirm.visible = true
		else:
			$AnimationPlayer.play_backwards("fade")
		slide = false
	if Global.current_character != Global.characters.find("arch"):
		$NewGame/Play.disabled = true
	else:
		$NewGame/Play.disabled = false
			
func menu(button, mouse_pos, button_pressed):
	if !slide:
		menu_position_offset = -mouse_pos/20
		sub_menu_position_offset = Vector2(-800,sub_menu_position_offset.y)
		button_pressed.modulate.a = opacity
		if opacity >= 0:
			opacity -= 1
	else:
		sub_menu_position_offset = -mouse_pos/20
		menu_position_offset = Vector2(-800,menu_position_offset.y)
		button_pressed.visible = true
		button_pressed.modulate.a = opacity
		if opacity <= 255:
			opacity += 1
	
	if is_instance_valid(button_pressed):
		button_pressed.global_position = lerp(button_pressed.global_position, sub_menu_position_offset, $BG.lerp_weight)
	$MenuText.global_position = lerp($MenuText.global_position, menu_position_offset, $BG.lerp_weight)

func quit_confirm() -> bool:
	$AnimationPlayer.play("quit_confirm")
	$QuitConfirm/ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	if $QuitConfirm.visible:
		return true
	else:
		return false

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"loading1":
			$Loading2.visible = false
		"loading_new_game":
			get_tree().change_scene_to_file("res://Scene/Level 1/level1.tscn")
		"loading_continue":
			get_tree().change_scene_to_file("res://Scene/Level 1/level1.tscn")

func _on_dash_animation_2_animation_finished(anim_name):
	$MenuText/Title/DashAnimation.play("dash")

func _on_bgm_delay_timeout():
	$BGSFX.play()

func _on_bgsfx_finished():
	$BGSFX.play()

#################################################################################

func _on_continue_pressed():
	#$AnimationPlayer.play("loading_continue")
	#$Loading2.mouse_filter = $Loading2.MOUSE_FILTER_STOP
	#play_sound("click")
	pass
func _on_new_game_pressed():
	play_sound("click")
	slide = true
	button = "NewGame"
	$AnimationPlayer.play("fade")
	pass


func _on_options_pressed():
	slide = true
	button = "Options"
	$AnimationPlayer.play("fade")
	play_sound("click")


func _on_credit_pressed():
	slide = true
	button = "Credit"
	$AnimationPlayer.play("fade")
	play_sound("click")

func _on_quit_pressed():
	play_sound("click")
	quit_confirm()

############################################################################################################

func _on_continue_mouse_entered():
	$MenuText/MarginContainer/VBoxContainer/Continue/LabelContinue.visible = true
	play_sound("hover")

func _on_continue_mouse_exited():
	$MenuText/MarginContainer/VBoxContainer/Continue/LabelContinue.visible = false

func _on_new_game_mouse_entered():
	$MenuText/MarginContainer/VBoxContainer/NewGame/LabelNewGame.visible = true
	play_sound("hover")
	
func _on_new_game_mouse_exited():
	$MenuText/MarginContainer/VBoxContainer/NewGame/LabelNewGame.visible = false

func _on_options_mouse_entered():
	$MenuText/MarginContainer/VBoxContainer/Options/LabelOptions.visible = true
	play_sound("hover")
	
func _on_options_mouse_exited():
	$MenuText/MarginContainer/VBoxContainer/Options/LabelOptions.visible = false
	
func _on_credit_mouse_entered():
	$MenuText/MarginContainer/VBoxContainer/Credit/LabelCredit.visible = true
	play_sound("hover")
	
func _on_credit_mouse_exited():
	$MenuText/MarginContainer/VBoxContainer/Credit/LabelCredit.visible = false

func _on_quit_mouse_entered():
	$MenuText/MarginContainer/VBoxContainer/Quit/LabelQuit.visible = true
	play_sound("hover")
	
func _on_quit_mouse_exited():
	$MenuText/MarginContainer/VBoxContainer/Quit/LabelQuit.visible = false



func _on_quit_quit_pressed():
	get_tree().quit()


func _on_quit_cancel_pressed():
	play_sound("click")
	$QuitConfirm/ColorRect.mouse_filter = Control.MOUSE_FILTER_PASS
	$AnimationPlayer.play_backwards("quit_confirm")


func _on_play_pressed():
	$Loading2.mouse_filter = $Loading2.MOUSE_FILTER_STOP
	play_sound("click")
	$AnimationPlayer.play("loading_new_game")


func _on_next_character_pressed():
	play_sound("click")
	if Global.current_character < Global.characters.size() - 1:
		Global.current_character += 1
	else:
		Global.current_character = 0


func _on_back_pressed():
	play_sound("click")
	back()
func _on_back_2_pressed():
	play_sound("click")
	back()

func _on_full_screen_toggled(button_pressed):
	if button_pressed:
		Global.fullscreen = 1
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.fullscreen = 0
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveLoad.save_data()
	
func _on_vsync_toggled(button_pressed):
	if button_pressed:
		Global.vsync = 1
		$Options/MarginContainer/VBoxContainer/VsyncWarning.visible = abs(Global.vsync - 1)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		Global.vsync = 0
		$Options/MarginContainer/VBoxContainer/VsyncWarning.visible = abs(Global.vsync - 1)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	SaveLoad.save_data()
	
func _on_show_fps_toggled(button_pressed):
	if button_pressed:
		Global.show_fps = 1
	else:
		Global.show_fps = 0
	SaveLoad.save_data()

func _on_ca_toggled(button_pressed):
	if button_pressed:
		Global.chromatic = 1
		$Chromatic.show()
	else:
		Global.chromatic = 0
		$Chromatic.hide()
	SaveLoad.save_data()
	
func _on_enable_particle_toggled(button_pressed):
	if button_pressed:
		Global.enable_particle = 1
	else:
		Global.enable_particle = 0
	SaveLoad.save_data()
	
func back():
	$AnimationPlayer.play_backwards("fade")
	slide = false


func _on_next_character_mouse_entered():
	play_sound("hover")


func _on_back_2_mouse_entered():
	play_sound("hover")


func _on_play_mouse_entered():
	play_sound("hover")


func _on_back_mouse_entered():
	play_sound("hover")


func _on_quit_cancel_mouse_entered():
	play_sound("hover")


func _on_quit_quit_mouse_entered():
	play_sound("hover")

	pass # Replace with function body.


