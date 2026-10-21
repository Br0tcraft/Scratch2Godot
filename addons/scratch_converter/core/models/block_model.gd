class_name ScratchBlockModel
extends RefCounted

enum BlockTypes {
    MOTION,
    LOOKS,
    SOUND,
    EVENT,
    CONTROL,
    SENSING,
    OPERATOR,
    DATA,
	PROCEDURES,
    UNKNOWN
}


var name: String = ""
var id: String = ""
var opcode: String = ""
var fields: Dictionary[String, ScratchFieldModel] = {}
var inputs: Dictionary[String, ScratchInputModel] = {}
var mutation: Dictionary = {}
var next: String = "" # id
var parent: String = "" # id
#var shadow: bool
#var topLevel: bool
#var x: float
#var y: float
var blockType: BlockTypes = BlockTypes.UNKNOWN


func load_from_dict(block_id: String, data: Dictionary, all_blocks_data: Dictionary) -> void:
	id = block_id

	opcode = data.get("opcode", "")
	var prefix := opcode.split("_")[0]
	blockType = BlockTypes.get(prefix.to_upper(), BlockTypes.UNKNOWN)

	next = data.get("next") if data.get("next") != null else &""
	parent = data.get("parent") if data.get("parent") != null else &""
	
	var fields_data = data.get("fields", {})
	for field_name in fields_data:
		var field := ScratchFieldModel.new()
		field.load_from_array(fields_data[field_name])
		fields[field_name] = field
		
	var inputs_data = data.get("inputs", {})
	for input_name in inputs_data:
		var input := ScratchInputModel.new()
		input.load_from_array(inputs_data[input_name], all_blocks_data)
		inputs[input_name] = input

	if data.get("mutation") is Dictionary:
		mutation = data["mutation"]
	ScratchLog.v("[BLOCK] " + BlockTypes.keys()[blockType])
	ScratchLog.v("\t- Id: " + str(id))
	ScratchLog.v("\t- Opcode: " + str(opcode))
	ScratchLog.v("\t- Fields: " + str(fields.keys()))
	ScratchLog.v("\t- Inputs: " + str(inputs.keys()))
	ScratchLog.v("\t- Next: " + str(next))
	ScratchLog.v("\t- Parent: " + str(parent))
