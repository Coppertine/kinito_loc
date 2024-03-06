extends Control
var text = "Welcome"

func get_rand_text(common_text_dict):
	randomize()
	
	var time = OS.get_datetime()
	var day = time["day"]
	var month = time["month"]
	
	if month == 12 and (day == 24 or day == 25):
		if int(rand_range(0,2)) == 1:
			text = common_text_dict["RAND_WELCOME_HOLIDAYS"]
		else:
			_rand(common_text_dict)
	elif month == 10 and (day == 31):
		if int(rand_range(0,2)) == 1:
			text = common_text_dict["RAND_WELCOME_HALLOWEEN"]
		else:
			_rand(common_text_dict)
	else:
		if(Tab.sp == 0):
			text = common_text_dict["RAND_WELCOME_BACK"]
		else:
			_rand(common_text_dict)
	if(Tab.sp == 0):
		text = common_text_dict["RAND_WELCOME_BACK"]
	return text

func _rand(common_text_dict):
	var top = 20
	top = clamp( (150/Tab.sp)+10, 0 ,20)
	var random = int(rand_range(0,top))
	if random == 0: text = common_text_dict["RAND_WELCOME_0"]
	elif random == 1: text = common_text_dict["RAND_WELCOME_1"]
	elif random == 2: text = common_text_dict["RAND_WELCOME_2"]
	elif random == 3: text = common_text_dict["RAND_WELCOME_3"]
	elif random == 4: text = common_text_dict["RAND_WELCOME_4"]
	elif random == 5: text = common_text_dict["RAND_WELCOME_5"]
	elif random == 6: text = common_text_dict["RAND_WELCOME_6"]
	elif random == 7: text = common_text_dict["RAND_WELCOME_7"]
	elif random == 8: text = common_text_dict["RAND_WELCOME_8"]
	elif random == 9: text = common_text_dict["RAND_WELCOME_9"]
	elif random == 10: text = common_text_dict["RAND_WELCOME_10"]
	elif random == 11: text = common_text_dict["RAND_WELCOME_11"]
	elif random == 12: text = common_text_dict["RAND_WELCOME_12"]
	elif random == 13: text = common_text_dict["RAND_WELCOME_13"]
	elif random == 14: text = common_text_dict["RAND_WELCOME_14"]
	elif random == 15: text = common_text_dict["RAND_WELCOME_15"]
	elif random == 16: text = common_text_dict["RAND_WELCOME_16"]
	elif random == 17: text = common_text_dict["RAND_WELCOME_17"]
	elif random == 18: text = common_text_dict["RAND_WELCOME_18"]
	elif random == 19: text = common_text_dict["RAND_WELCOME_19"]
	elif random == 20: text = common_text_dict["RAND_WELCOME_20"]
