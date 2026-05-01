extends CanvasLayer

@onready var joystick_base = $JoystickBase
@onready var joystick_handle = $JoystickBase/JoystickHandle

var joystick_active = false
var max_distance = 80.0
var joystick_vector = Vector2.ZERO

@onready var run_btn = $RunButton
@onready var interact_btn = $InteractButton
@onready var flashlight_btn = $FlashlightButton

func _ready():
	visible = (GlobalAyarlar.platform_mode == "Mobile")
	
	set_process(true)

func _process(_delta):
	if GlobalAyarlar.platform_mode == "PC" or OS.has_feature("pc"):
		var center_offset = (joystick_base.size / 2.0) - (joystick_handle.size / 2.0)
		var wasd_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if wasd_dir.length() > 0:
			joystick_handle.position = center_offset + (wasd_dir * max_distance / 2.0)
		elif not joystick_active:
			joystick_handle.position = center_offset


func _input(event):
	if not visible: return

	if event is InputEventScreenTouch:
		if event.pressed:
			if joystick_base.get_global_rect().has_point(event.position):
				joystick_active = true
		else:
			joystick_active = false
			var center_offset = (joystick_base.size / 2.0) - (joystick_handle.size / 2.0)
			joystick_handle.position = center_offset
			joystick_vector = Vector2.ZERO

	if event is InputEventScreenDrag and joystick_active:
		var center = joystick_base.global_position + joystick_base.size / 2.0
		var dist = event.position - center
		
		if dist.length() > max_distance:
			dist = dist.normalized() * max_distance
			
		var center_offset = (joystick_base.size / 2.0) - (joystick_handle.size / 2.0)
		joystick_handle.position = center_offset + dist
		joystick_vector = dist / max_distance


func _on_run_button_down():
	Input.action_press("sprint")

func _on_run_button_up():
	Input.action_release("sprint")

func _on_interact_button_pressed():
	var ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	Input.parse_input_event(ev)
	
	await get_tree().create_timer(0.05).timeout
	
	var ev2 = InputEventAction.new()
	ev2.action = "interact"
	ev2.pressed = false
	Input.parse_input_event(ev2)

func _on_flashlight_button_pressed():
	Input.action_press("fener_ac_kapa")
	
	var ev = InputEventKey.new()
	ev.keycode = KEY_F
	ev.physical_keycode = KEY_F
	ev.pressed = true
	Input.parse_input_event(ev)
	
	await get_tree().create_timer(0.05).timeout
	
	Input.action_release("fener_ac_kapa")
	var ev_up = InputEventKey.new()
	ev_up.keycode = KEY_F
	ev_up.physical_keycode = KEY_F
	ev_up.pressed = false
	Input.parse_input_event(ev_up)

func _on_crouch_button_down():
	Input.action_press("crouch")

func _on_crouch_button_up():
	Input.action_release("crouch")

func _on_pause_button_pressed():
	if is_instance_valid(Pausescreen):
		Pausescreen.toggle_pause()
	else:
		var p = get_tree().root.find_child("pausescreen", true, false)
		if p and p.has_method("toggle_pause"):
			p.toggle_pause()

func get_joystick_vector() -> Vector2:
	return joystick_vector

func _on_quest_button_pressed():
	var ev = InputEventKey.new()
	ev.keycode = KEY_TAB
	ev.physical_keycode = KEY_TAB
	ev.pressed = true
	Input.parse_input_event(ev)
	
	await get_tree().create_timer(0.5).timeout
	
	var ev_up = InputEventKey.new()
	ev_up.keycode = KEY_TAB
	ev_up.physical_keycode = KEY_TAB
	ev_up.pressed = false
	Input.parse_input_event(ev_up)

func _on_grafik_toggle_pressed():
	var panel = get_node_or_null("GraphicsPanel")
	if panel:
		panel.visible = !panel.visible

func _on_grafik_dusuk_pressed():
	GlobalAyarlar.grafik_ayarla("Dusuk")
	_hide_grafik_panel()

func _on_grafik_orta_pressed():
	GlobalAyarlar.grafik_ayarla("Orta")
	_hide_grafik_panel()

func _on_grafik_yuksek_pressed():
	GlobalAyarlar.grafik_ayarla("Yuksek")
	_hide_grafik_panel()

func _hide_grafik_panel():
	var panel = get_node_or_null("GraphicsPanel")
	if panel:
		panel.visible = false
