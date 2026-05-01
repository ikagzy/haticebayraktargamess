
@tool

var success := false
var value = null
var message := ""
var inner_result = null


func _init(p_success: bool, p_message := "", p_inner = null):
	success = p_success
	message = p_message
	inner_result = p_inner


func with_value(v):
	value = v
	return self


func get_message() -> String:
	var msg := message
	if inner_result != null:
		msg += "\n"
		msg += inner_result.get_message()
	return msg


func is_ok() -> bool:
	return success
