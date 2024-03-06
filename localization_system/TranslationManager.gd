extends Node2D

var files_loaded = false

var patched_pc = false
var patched_desktop = false
var patched_dialogue = false

var current_lang = "en"

#region Classes
var KinitoLocalizedText = preload("res://localization_system/AllLocalizedData.gd")
var kinito_loc = KinitoLocalizedText.new()

var KinitoWelcomeMsgs = preload("res://localization_system/ModifiedSource/WelcomeBackMsgs.gd")
var kinito_wmsgs = KinitoWelcomeMsgs.new()

var ResetGameData = preload("res://localization_system/ModifiedSource/ResetGameData.gd")
var reset_data = ResetGameData.new()

#endregion

func load_translation_files(lang):
	print("loading translation files for %s" % lang)
	var dio_path = "user://localization/%s/dialogue_data.json" % lang
	var cmn_path = "user://localization/%s/common_text_data.json" % lang
	
	var file : File = File.new()
	
	print("loading kinito lines")
	if file.file_exists(dio_path) == true:
		file = File.new()
		file.open(dio_path, File.READ)
		
		var error = JSON.parse(file.get_as_text())
		print(error)
		kinito_loc.kinito_dialogue = error.result
		
		file.close()
	else:
		print("kinito lines doesn't exist for %s.. ignoring" % lang)
		
	print("loading common lines")
	if file.file_exists(cmn_path) == true:
		file = File.new()
		file.open(cmn_path, File.READ)
		
		var error = JSON.parse(file.get_as_text())
		kinito_loc.kinito_common_text = error.result
		
		file.close()
	else:
		print("common lines doesn't exist for %s.. ignoring" % lang)
				
	patched_dialogue = false
	patched_pc = false
	patched_desktop = false
	
	return true
	
func patch_kinito_dialogue(animation, dialogue, audio):
	var text_track = animation.find_track("Pet/Pet/tts/tts/tts/SpeachBubble/Text:bbcode_text")
	var aud_track = animation.find_track("Dio/AUDIOLINES/LINE:stream")
	
	if dialogue != null:
		for n in range(animation.track_get_key_count(text_track)):
			animation.track_set_key_value(text_track, n, dialogue[n])

	for n in range(animation.track_get_key_count(aud_track)):
		if audio[n] != null or audio[n] != "":
			var audio_file = load(audio[n])
			while(audio_file == null):
				yield(get_tree(), "idle_frame")
				
			animation.track_set_key_value(aud_track, n, audio_file)
				
func _ready():
	files_loaded = load_translation_files("en")
	
func _show_node_paths():
	var path = $CanvasLayer/LineEdit.text
	var last_path = ""
	
	if get_parent().get_parent().get_node(path) != null and last_path != path:
		$CanvasLayer/ColorRect/RichTextLabel2.bbcode_text = ""
		for node in get_parent().get_parent().get_node(path).get_children():
			$CanvasLayer/ColorRect/RichTextLabel2.bbcode_text += node.name + "\n"
			
		last_path = path

func _show_localized():
	var path = $CanvasLayer/LineEdit2.text
	var last_path = ""
	
	if kinito_loc.kinito_common_text[path] != null and last_path != path:
		$CanvasLayer/ColorRect2/RichTextLabel2.bbcode_text = kinito_loc.kinito_common_text[path]
		last_path = path

func _patch_computer_app(app_name, localized_name):
	var app = get_parent().get_parent().get_node("0").get_node("PC/Aspect/" + app_name)

	if app != null:
		app.get_node("Drag/Title/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Drag/Title/Shadow/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Title/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Title/Shadow/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
	
func _patch_app000():
	if Tab.data["open"][0] == true:
		var welcome_text
		var password_text = get_parent().get_parent().get_node("0").get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s2/LoginScreen/PasswordBox/Password TextEdit")
		
		var troy_en_text = get_parent().get_parent().get_node("0").get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0-1/Bootscreen")
		var boot_text = get_parent().get_parent().get_node("0").get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0/Bootscreen")
		
		if !patched_pc:
			#Aspect/Aspect/s2/LoginScreen/PasswordBox/Password TextEdit
			welcome_text = get_parent().get_parent().get_node("0").get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s2/LoginScreen/Messages/WelcomeBack")		
			if welcome_text != null:
				welcome_text.bbcode_text = "\n[center]"+kinito_wmsgs.get_rand_text(kinito_loc.kinito_common_text)+"\n"
				print("Patched PC Welcome Text")
			patched_pc = true
			
		if troy_en_text != null:
			troy_en_text.bbcode_text = kinito_loc.kinito_common_text["COMMON_A_GAME_BY"]
			print("Patched Boot credits")
		if boot_text != null:
			boot_text.bbcode_text = kinito_loc.kinito_common_text["COMMON_BOOT_SCREEN"]
			print("Patched Boot Screen")
		if password_text != null:
			#$CanvasLayer/ColorRect/RichTextLabel2.bbcode_text = "Path\n\n" + kinito_loc.kinito_common_text["COMMON_PASSWORD"]
			password_text.placeholder_text = kinito_loc.kinito_common_text["COMMON_PASSWORD"]
			
		if !patched_desktop and get_parent().get_parent().get_node("0/PC/Aspect/") != null:
			_patch_computer_app("My_Computer", "PC_APPS_MYCOMPUTER")
			_patch_computer_app("Settings", "PC_APPS_SETTINGS")
			_patch_computer_app("The_Internet", "PC_APPS_INTERNET")
			_patch_computer_app("My_Pictures", "PC_APPS_PICTURES")
			_patch_computer_app("My_Music", "PC_APPS_MUSIC")
			_patch_computer_app("Close_Game", "PC_APPS_PAUSE")
			_patch_computer_app("Mine_Sweeper", "PC_APPS_MINESWEEPER")
			_patch_computer_app("3D_Pinball", "PC_APPS_PINBALL")
			_patch_computer_app("OS_Paint", "PC_APPS_PAINT")
			print("Patched desktop app shotcuts")
			patched_desktop = true
				
func _patch_app001():
	if Tab.data["open"][1] == true:
		var dio : AnimationPlayer = get_parent().get_parent().get_node("1").get_node("MAIN_KINITO/Main/Dio")
		#var text : RichTextLabel = get_parent().get_parent().get_node("1").get_node("MAIN_KINITO/Main/Pet/Pet/tts/tts/tts/SpeachBubble/Text")	
		
		if !patched_dialogue:	
			for name in dio.get_animation_list():
				patch_kinito_dialogue(dio.get_animation(name), (kinito_loc.kinito_dialogue[name])[0], (kinito_loc.kinito_dialogue[name])[1])
			print("Patched kinito's TTS lines")
			patched_dialogue = true

func _patch_app003():
	if Tab.data["open"][3] == true:
		var window_title_1 = get_parent().get_parent().get_node("3").get_node("Tab/Active/Title")
		var window_header_1 = get_parent().get_parent().get_node("3").get_node("Tab/Active/ASSET/1/Title")
		var window_text_1 = get_parent().get_parent().get_node("3").get_node("Tab/Active/ASSET/1/Text")
		
		var window_title_2 = get_parent().get_parent().get_node("3").get_node("@Tab@73/Active/Title")
		var window_header_2 = get_parent().get_parent().get_node("3").get_node("@Tab@73/Active/ASSET/1/TITLE")
		var window_text_2 = get_parent().get_parent().get_node("3").get_node("@Tab@73/Active/ASSET/1/TEXT")
		
		var window_button_1 = get_parent().get_parent().get_node("3").get_node("Tab/Active/ASSET/1/NEST")
		var window_button_2 = get_parent().get_parent().get_node("3").get_node("@Tab@73/Active/ASSET/1/Okayt")
		
		if window_title_1 != null:
			window_title_1.text = kinito_loc.kinito_common_text["WINDOW_TITLE_WELCOME"]
		if window_title_2 != null:
			window_title_2.text = kinito_loc.kinito_common_text["WINDOW_TITLE_HOWTO"]
			
		if window_header_1 != null:
			window_header_1.text = kinito_loc.kinito_common_text["WINDOW_CONTENTW_HEADER"]
		if window_header_2 != null:
			window_header_2.text = kinito_loc.kinito_common_text["WINDOW_HOWTO_HEADER"]
				
		if window_text_1 != null:
			window_text_1.bbcode_text = kinito_loc.kinito_common_text["WINDOW_CONTENTW"]
		if window_text_2 != null:
			window_text_2.text = kinito_loc.kinito_common_text["WINDOW_HOWTO"]
			
		if window_button_1 != null:
			window_button_1.text = kinito_loc.kinito_common_text["COMMON_CONTINUE"]
		if window_button_2 != null:
			window_button_2.text = kinito_loc.kinito_common_text["COMMON_OK"]

func _patch_app007():
	var patched_button = false
	if Tab.data["open"][7] == true:
		var tab = get_parent().get_parent().get_node("7").get_node("Tab")
		
		var window_title = get_parent().get_parent().get_node("7").get_node("Tab/Active/Title2")
		var window_header = get_parent().get_parent().get_node("7").get_node("Tab/Active/Title")
		
		var last_save = get_parent().get_parent().get_node("7").get_node("Tab/Active/LastSave")
		var volume_title = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/TitleVolume/Title")
		
		var master_volume = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider1/Title")
		var kbm_volume = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider2/Title")
		var ambient_volume = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider3/Title")
		var music_volume = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider4/Title")
		
		var bg_title = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Title")

		var windowed_mode = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text2")
		var desk_bg = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text")
		var allow_effects = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text 2")
		var streamer_mode = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text3")
		var act3_vhs = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text4")
		
		var data_title = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/TITLE")
		
		var reset_button = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control/Button")
		var reset_desc = get_parent().get_parent().get_node("7").get_node("Tab/Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control/sub_text")
		
		var finish = get_parent().get_parent().get_node("7").get_node("Tab/Active/CANCEL")
		
		window_title.text = kinito_loc.kinito_common_text["WINDOW_TITLE_SETTINGS"]
		window_header.text = kinito_loc.kinito_common_text["PC_SETTINGS"]
		
		volume_title.text = kinito_loc.kinito_common_text["PC_SETTINGS_VOLUME"]
		
		master_volume.text = kinito_loc.kinito_common_text["PC_SETTINGS_MASTER"]
		kbm_volume.text = kinito_loc.kinito_common_text["PC_SETTINGS_KBM"]
		ambient_volume.text = kinito_loc.kinito_common_text["PC_SETTINGS_AMBIENT"]
		music_volume.text = kinito_loc.kinito_common_text["PC_SETTINGS_MUSIC"]
		
		bg_title.text = kinito_loc.kinito_common_text["PC_SETTINGS_BACKGROUND"]
		
		windowed_mode.bbcode_text = kinito_loc.kinito_common_text["PC_SETTINGS_WINMODE"]
		desk_bg.bbcode_text = kinito_loc.kinito_common_text["PC_SETTINGS_DESKTOPBG"]
		allow_effects.bbcode_text = kinito_loc.kinito_common_text["PC_SETTINGS_DESKTOPEFFECT"]
		streamer_mode.bbcode_text = kinito_loc.kinito_common_text["PC_SETTINGS_STREAMER"]
		act3_vhs.bbcode_text = kinito_loc.kinito_common_text["PC_SETTINGS_ACT3"]
		
		data_title.text = kinito_loc.kinito_common_text["PC_SETTINGS_DATA"]
		
		reset_button.text = kinito_loc.kinito_common_text["PC_SETTINGS_RESET"]
		
		if !patched_button:
			reset_button.disconnect("button_up", tab, "_on_Button_button_up")
			reset_button.connect("button_up", reset_data, "reset_game_data_button", [tab,kinito_loc.kinito_common_text])
			patched_button = true
		
		reset_desc.text = kinito_loc.kinito_common_text["PC_SETTINGS_RESETDESC"]
		
		finish.text = kinito_loc.kinito_common_text["COMMON_FINISH"]
		last_save.text = kinito_loc.kinito_common_text["COMMON_LSAVED"] % Data.data["lastSave"]

func _patch_app010():
	#NROOT/_/Active/Label
	if Tab.data["open"][10] == true:
		var last_save = get_parent().get_parent().get_node("10").get_node("NROOT/_/Active/Label")
		if last_save != null:
			last_save.text = kinito_loc.kinito_common_text["COMMON_LSAVED"] % Data.data["lastSave"]


func _process(delta):
	# Patch intro screen (PC)
	_show_node_paths()
	if files_loaded:
		if Input.is_key_pressed(KEY_TAB):
			print("Reloading translation files...")
			files_loaded = load_translation_files("en")
		
		_show_localized()
		
		if Data.data["lastSave"] == "never":
			Data.data["lastSave"] = kinito_loc.kinito_common_text["COMMON_LSAVED_NEVER"]
		
		_patch_app000()
		_patch_app001()
		_patch_app003()
		_patch_app007()
		_patch_app010()

