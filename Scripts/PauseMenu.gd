extends Control

func _ready():
	self.hide()

func _process(delta):
	testEsc()

func resume():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.hide()
	
func pause():
	get_tree().paused = true
	print(Input.mouse_mode)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	self.show()
	
func testEsc():
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _on_resume_button_pressed():
	resume()
	
func _on_quit_button_pressed():
	get_tree().quit()

func _on_morning_button_pressed():
	Messenger.TIME_SET_MORNING.emit()

func _on_day_button_pressed():
	Messenger.TIME_SET_DAY.emit()

func _on_evening_button_pressed():
	Messenger.TIME_SET_EVENING.emit()

func _on_night_button_pressed():
	Messenger.TIME_SET_NIGHT.emit()
