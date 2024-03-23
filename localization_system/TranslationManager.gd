extends Node2D

var files_loaded = false

var patched_pc = false
var patched_desktop = false
var patched_dialogue = false
var patched_funfair = false
var patched_your_home = false

var default_config = {
	"LANGUAGE": "en",
	"SHOW_DEBUG_CONSOLES": false
}
var config = {}
var current_lang = ""
var config_loaded = false
var config_node
#region Classes
var KinitoLocalizedText = preload("res://localization_system/AllLocalizedData.gd")
var kinito_loc = KinitoLocalizedText.new()

var KinitoWelcomeMsgs = preload("res://localization_system/ModifiedSource/WelcomeBackMsgs.gd")
var kinito_wmsgs = KinitoWelcomeMsgs.new()

var ResetGameData = preload("res://localization_system/ModifiedSource/ResetGameData.gd")
var reset_data = ResetGameData.new()

#endregion

func config_handler():
	var dir = Directory.new()
	dir.open("user://Mods")
	if (dir.file_exists("!ModConfiguration.zip")):
		while config_loaded == false:
			if get_parent().has_node("Config_Scene"):
				config_node = get_parent().get_node("Config_Scene")
				var config_file = config_node.MakeConfig("localization",default_config)
				config = config_node.values
				config_loaded = true
			yield(get_tree().create_timer(0.1,false),"timeout")
	else:
		print_log("Can not find Mod Configuration, using default settings")
		config_loaded = true
	pass

func load_translation_files(lang):
	print_log("loading translation files for %s" % lang)
	var dio_path = "user://localization/%s/dialogue_data.json" % lang
	var cmn_path = "user://localization/%s/common_text_data.json" % lang
	
	var file : File = File.new()
	
	print_log("loading kinito lines")
	if file.file_exists(dio_path) == true:
		file = File.new()
		file.open(dio_path, File.READ)
		
		var error = JSON.parse(file.get_as_text())
		print(error)
		kinito_loc.kinito_dialogue = error.result
		
		file.close()
	else:
		print_log("kinito lines doesn't exist for %s.. ignoring" % lang)
		
	print_log("loading common lines")
	if file.file_exists(cmn_path) == true:
		file = File.new()
		file.open(cmn_path, File.READ)
		
		var error = JSON.parse(file.get_as_text())
		kinito_loc.kinito_common_text = error.result
		
		file.close()
	else:
		print_log("common lines doesn't exist for %s.. ignoring" % lang)
				
	patched_dialogue = false
	patched_pc = false
	patched_desktop = false
	
	return true
	
func patch_kinito_dialogue(animation, dialogue, audio):
	var text_track = animation.find_track("Pet/Pet/tts/tts/tts/SpeachBubble/Text:bbcode_text")
	var aud_track = animation.find_track("Dio/AUDIOLINES/LINE:stream")
	
	if text_track != -1 and dialogue != null:
		for n in range(animation.track_get_key_count(text_track)):
			animation.track_set_key_value(text_track, n, dialogue[n])
	if aud_track != -1:
		for n in range(animation.track_get_key_count(aud_track)):
			if audio[n] != null or audio[n] != "":
				var audio_file = load(audio[n])
				while(audio_file == null):
					yield(get_tree(), "idle_frame")
				animation.track_set_key_value(aud_track, n, audio_file)
				
func _ready():
	config = default_config
	config_handler()
	while !config_loaded: # _ready() has to wait up before the config is fully loaded
		yield(get_tree().create_timer(0.1,false),"timeout")

	for child_node in $CanvasLayer.get_children():
		child_node.visible = config["SHOW_DEBUG_CONSOLES"] == "True"

	current_lang = config["LANGUAGE"]
	
	files_loaded = load_translation_files(current_lang)
	
	
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
	if get_parent().get_parent().has_node("0/PC/Aspect/"+app_name):
		print_log("patching app: " + app_name)
		var app = get_parent().get_parent().get_node("0").get_node("PC/Aspect/"+app_name)
		app.get_node("Drag/Title/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Drag/Title/Shadow/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Title/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]
		app.get_node("Title/Shadow/dks_title").bbcode_text = "[center]" + kinito_loc.kinito_common_text[localized_name]

var patched_boot_credits = false
var patched_boot_screen = false
var patched_password_text = false
func _patch_app000():
	if Tab.data["open"][0] == true and get_parent().get_parent().has_node("0"):
		var node_0 = get_parent().get_parent().get_node("0")
		if !patched_pc and node_0.has_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect"):
			#Aspect/Aspect/s2/LoginScreen/PasswordBox/Password TextEdit
			var welcome_text = node_0.get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s2/LoginScreen/Messages/WelcomeBack")		
			if welcome_text != null:
				welcome_text.bbcode_text = "\n[center]"+kinito_wmsgs.get_rand_text(kinito_loc.kinito_common_text)+"\n"
				print_log("Patched PC Welcome Text")
			patched_pc = true
				
		if !patched_boot_credits and node_0.has_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0-1/Bootscreen"):
			node_0.get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0-1/Bootscreen").bbcode_text = kinito_loc.kinito_common_text["COMMON_A_GAME_BY"]
			print_log("Patched Boot credits")
			patched_boot_credits = true
		if node_0.has_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0/Bootscreen"):
			node_0.get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s0/Bootscreen").bbcode_text = kinito_loc.kinito_common_text["COMMON_BOOT_SCREEN"]
			print_log("Patched Boot Screen")
			patched_boot_screen = true
		if !patched_password_text and node_0.has_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s2/LoginScreen/PasswordBox/Password TextEdit"):
			#$CanvasLayer/ColorRect/RichTextLabel2.bbcode_text = "Path\n\n" + kinito_loc.kinito_common_text["COMMON_PASSWORD"]
			node_0.get_node("C/PC/Input/Viewport/NROOT/Aspect/Aspect/s2/LoginScreen/PasswordBox/Password TextEdit").placeholder_text = kinito_loc.kinito_common_text["COMMON_PASSWORD"]
			
		if !patched_desktop and get_parent().get_parent().has_node("0/PC/Aspect/"):
			_patch_computer_app("My_Computer", "PC_APPS_MYCOMPUTER")
			_patch_computer_app("Settings", "PC_APPS_SETTINGS")
			_patch_computer_app("The_Internet", "PC_APPS_INTERNET")
			_patch_computer_app("My_Pictures", "PC_APPS_PICTURES")
			_patch_computer_app("My_Music", "PC_APPS_MUSIC")
			_patch_computer_app("Close_Game", "PC_APPS_PAUSE")
			_patch_computer_app("Mine_Sweeper", "PC_APPS_MINESWEEPER")
			_patch_computer_app("3D_Pinball", "PC_APPS_PINBALL")
			_patch_computer_app("OS_Paint", "PC_APPS_PAINT")
			print_log("Patched desktop app shotcuts")
			patched_desktop = true
				
func _patch_app001():
	if Tab.data["open"][1] and get_parent().get_parent().has_node("1/MAIN_KINITO/Main/Dio"):
		var dio : AnimationPlayer = get_parent().get_parent().get_node("1/MAIN_KINITO/Main/Dio")
		#var text : RichTextLabel = get_parent().get_parent().get_node("1").get_node("MAIN_KINITO/Main/Pet/Pet/tts/tts/tts/SpeachBubble/Text")	
		
		if !patched_dialogue:
			for name in dio.get_animation_list():
				if dio.has_animation(name):
					patch_kinito_dialogue(dio.get_animation(name), (kinito_loc.kinito_dialogue[name])[0], (kinito_loc.kinito_dialogue[name])[1])
			print_log("Patched kinito's TTS lines")
			patched_dialogue = true

func _patch_app003():
	if Tab.data["open"][3] == true:
		var node_3 = get_parent().get_parent().get_node("3")
		
		if node_3.has_node("Tab/Active"): # window (content warning / readme)
			if node_3.has_node("Tab/Active/Title"):
				node_3.get_node("Tab/Active/Title").text = kinito_loc.kinito_common_text["WINDOW_TITLE_WELCOME"]
			if node_3.has_node("Tab/Active/ASSET/1/Text"):
				node_3.get_node("Tab/Active/ASSET/1/Text").bbcode_text = kinito_loc.kinito_common_text["WINDOW_CONTENTW"]
			if node_3.has_node("Tab/Active/ASSET/1/Title"):
				node_3.get_node("Tab/Active/ASSET/1/Title").text = kinito_loc.kinito_common_text["WINDOW_CONTENTW_HEADER"]
			if node_3.has_node("Tab/Active/ASSET/1/NEST"): # window button
				node_3.get_node("Tab/Active/ASSET/1/NEST").text = kinito_loc.kinito_common_text["COMMON_CONTINUE"]

		# TODO: THIS NEEDS TO CHANGE to using get_child(0)
		if node_3.has_node("@Tab@73/Active"):
			if node_3.has_node("@Tab@73/Active/Title"):
				node_3.get_node("@Tab@73/Active/Title").text = kinito_loc.kinito_common_text["WINDOW_TITLE_HOWTO"]
			if node_3.has_node("@Tab@73/Active/ASSET/1/TITLE"):
				node_3.get_node("@Tab@73/Active/ASSET/1/TITLE").text = kinito_loc.kinito_common_text["WINDOW_HOWTO_HEADER"]
			if node_3.has_node("@Tab@73/Active/ASSET/1/TEXT"):
				node_3.get_node("@Tab@73/Active/ASSET/1/TEXT").text = kinito_loc.kinito_common_text["WINDOW_HOWTO"]
			if node_3.has_node("@Tab@73/Active/ASSET/1/Okayt"):
				node_3.get_node("@Tab@73/Active/ASSET/1/Okayt").text = kinito_loc.kinito_common_text["COMMON_OK"]

func _patch_app007():
	var patched_button = false
	if Tab.data["open"][7] and get_parent().get_parent().get_node("7").has_node("Tab/Active"):
		var tab = get_parent().get_parent().get_node("7").get_node("Tab")
		
		var window_title = tab.get_node("Active/Title2")
		var window_header = tab.get_node("Active/Title")
		
		var last_save = tab.get_node("Active/LastSave")
		var volume_title = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/TitleVolume/Title")
		
		var master_volume = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider1/Title")
		var kbm_volume = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider2/Title")
		var ambient_volume = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider3/Title")
		var music_volume = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Slider4/Title")
		
		var bg_title = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Title")

		var windowed_mode = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text2")
		var desk_bg = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text")
		var allow_effects = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text 2")
		var streamer_mode = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text3")
		var act3_vhs = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control2/sub_text4")
		
		var data_title = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/TITLE")
		
		var reset_button = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control/Button")
		var reset_desc = tab.get_node("Active/ScrollContainer/HBoxContainer/Control/ASSET/1/Control/sub_text")
		
		var finish = tab.get_node("Active/CANCEL")
		
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
	if Tab.data["open"][10] and get_parent().get_parent().get_node("10").has_node("NROOT/_/Active/Label"):
		var last_save = get_parent().get_parent().get_node("10/NROOT/_/Active/Label")
		last_save.text = kinito_loc.kinito_common_text["COMMON_LSAVED"] % Data.data["lastSave"]

func _patch_funfair():
	# good thing it's only 1 object..
	if !patched_funfair and App.data["data"][4] == "FUNFAIR_INITLOAD" and get_tree().current_scene().has_node("Main/FunFair"):
		print_log("Patching funfair dialog")
		get_tree().current_scene().get_node("Main/FunFair/Funland/StoryArea/[desc] A miniature version of your funfair").name = "[desc] " + kinito_loc.kinito_common_text["YWRD_FFAIR_MINI"]
		patched_funfair = true
		
func _patch_your_home():
	if !patched_your_home and App.data["data"][4] == "FUNFAIR_NOCRASH_coaster" and get_tree().current_scene().has_node("House"): #assuming they are in tunnel
		print_log("Patching your_home dialog")
		patched_your_home = true
func _process(delta):
	# Patch intro screen (PC)
	_show_node_paths()
	if files_loaded:
		if Input.is_key_pressed(KEY_TAB):
			print_log("Reloading translation files...")
			files_loaded = load_translation_files("en")
		
		_show_localized()
		
		if Data.data["lastSave"] == "never":
			Data.data["lastSave"] = kinito_loc.kinito_common_text["COMMON_LSAVED_NEVER"]
		
		_patch_notes()
		_patch_email()
		_patch_app000()
		_patch_app001()
		_patch_app003()
		_patch_app007()
		_patch_app010()
		_patch_funfair()
		_patch_your_home()
func print_log(line):
	print("[localization] ", line)
