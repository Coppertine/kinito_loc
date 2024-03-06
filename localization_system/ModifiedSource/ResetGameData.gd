extends Node

func reset_game_data_button(tb, common_text):
	var msgBox = Tab.msgBox(common_text["WINDOW_TITLE_RESET"], common_text["PC_SETTINGS_RESETCONFIRM"], 2, common_text["COMMON_YES"], common_text["COMMON_NO"], 0) 
	
	if msgBox is GDScriptFunctionState:
		msgBox = yield(msgBox, "completed")
		
	if(msgBox == 1):
		Wallpaper.call("M0")
		
		if(App.data["dskhide"] == 0 and Desktop.isVisible() == 1):
			Desktop.ToggleDesktopIcons()
			
		App._resetAll()
		tb.remove_folder("user://Kinitopet_DATA/Wallpaper_DATA")
		tb.remove_folder("user://Kinitopet_DATA/")
		tb.remove_folder("user://")
		App._allClose()
