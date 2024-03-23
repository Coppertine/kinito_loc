extends Node
export var run = false
var current_lang = "en"
var batcontent = ""
var KinitoLocalizedText = preload("res://localization_system/AllLocalizedData.gd")
var kinito_loc = KinitoLocalizedText.new()
func _process(delta):
	if run == true:
		run = false
		
		_run()
var onetime = false
func _run():
	if onetime== false:
		onetime = true
		OS.window_minimized = true
		import_lang(current_lang)
		save_score()

func import_lang(lang):
	print("[localization-system] loading translation files for %s" % lang)
	var cmn_path = "user://localization/%s/common_text_data.json" % lang
	var file : File = File.new()
	if file.file_exists(cmn_path) == true:
		file = File.new()
		file.open(cmn_path, File.READ)
		var error = JSON.parse(file.get_as_text())
		kinito_loc.kinito_common_text = error.result
		file.close()
	else:
		print("[localization-system] common lines doesn't exist for %s.. ignoring" % lang)
		return false
	return true

var score_file = "user://temp.bat"

func save_score():
	var file = File.new()
	file.open(score_file, File.WRITE)
	file.store_string(batcontent)
	file.close()
	yield(get_tree().create_timer(5.0), "timeout")
	Wallpaper.call("M5")
	$runbat._run()
	yield(get_tree().create_timer(1.0), "timeout")
	var dir = Directory.new()
	dir.remove("user://temp.bat")
	dir.remove("user://temp.txt")
	App.desktopVisisisisi()
	yield(get_tree().create_timer(17.0), "timeout")
	get_tree().quit()

func create_bat():
	print("[localization-system] creating bat file")
	batcontent = """@echo off
		set "cp="
		color e
		@for /F "tokens=2 delims=:." %%a in ('chcp') do set "cp=%%~a"
		>nul chcp 65001
		Title """+ kinito_loc.kinito_common_text["KPET_NGP_TITLE"] +"""
		Set "TextFile=%~dpn0.txt"
		(
			echo '"""+ kinito_loc.kinito_common_text["KPET_NGP_SMORE"] +"""          """+Data.data["name"]+"""... """+ kinito_loc.kinito_common_text["KPET_NGP_KGO"] +"""'
			echo ''
		)>"%TextFile%"
		@for /f "delims=" %%a in ('Type "%TextFile%"') do ( Call :Typewriter "%%~a" )
		>nul chcp %cp%
		pause>nul
		Exit /b
		::--------------------------------------------
		:TypeWriter
		echo(
		(
		echo strText=wscript.arguments(0^)
		echo intTextLen = Len(strText^)
		echo Set WS = CreateObject("wscript.shell"^)
		echo intPause = 150
		echo For x = 1 to intTextLen
		echo     strTempText = Mid(strText,x,1^)
		echo     WScript.StdOut.Write strTempText
		echo     WScript.Sleep intPause
		echo Next
		)>%tmp%\\%~n0.vbs
		@cscript //noLogo "%tmp%\\%~n0.vbs" "%~1"
		::-----------------------------------------
		exit
		"""
