class_name ScratchInputModel
extends RefCounted

enum InputType {VALUE, BLOCK_REF, VARIABLE, LIST}

var type: InputType = InputType.VALUE
var value: Variant = null
var block_id: String = ""
var is_list: bool = false

const SHADOW_OPCODES = {
	"math_number": "NUM",
	"text": "TEXT",
	"math_integer": "NUM",
	"math_whole_number": "NUM"
}


func load_from_array(input_array: Array, all_blocks_data: Dictionary) -> void:
	if input_array.is_empty():
		return
		
	var scratch_type := int(input_array[0])
	var input_value = input_array[1]
	
	if scratch_type == 1 and input_value is Array:
		type = InputType.VALUE
		value = _parse_primitive_value(input_value)
		
	elif (scratch_type == 2 or scratch_type == 3) and input_value is Array:
		type = InputType.LIST if input_value[0] == 13 else InputType.VARIABLE
		value = str(input_value[1]) # Name
		block_id = input_value[2] # ID
		
	elif input_value is String:
		var target_id := input_value as String
		
		if all_blocks_data.has(target_id) and all_blocks_data[target_id].get("opcode") in SHADOW_OPCODES:
			var shadow_block = all_blocks_data[target_id]
			var inner_field_name = SHADOW_OPCODES[shadow_block["opcode"]]
			var field_data = shadow_block.get("fields", {}).get(inner_field_name, [])
			
			type = InputType.VALUE
			value = str(field_data[0]) if not field_data.is_empty() else ""
		else:
			type = InputType.BLOCK_REF
			block_id = target_id
	ScratchLog.v("[INPUT] " + InputType.keys()[type])
	ScratchLog.v("\t- Value: " + str(value))
	ScratchLog.v("\t- Block Id: " + str(block_id))
	ScratchLog.v("\t- Is List: " + str(is_list))


func _parse_primitive_value(val_array: Array) -> Variant:
	if val_array.size() > 1:
		var actual_val = val_array[1]
		if str(actual_val).is_valid_float():
			return str(actual_val).to_float()
		return str(actual_val)
	return ""