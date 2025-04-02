class_name correctur extends Node

static func ms(value, type, path, block):
	# Blöcke mit Standardwerten für NaN und Infinity
	var block_behaviors = {
		"move steps (!)": { "nan": 0, "inf": value },
		"go to x:(!) y:()": { "nan": 0, "inf": value },
		"go to x:() y:(!)": { "nan": 0, "inf": value },
		"change x by (!)": { "nan": 0, "inf": value },
		"change y by (!)": { "nan": 0, "inf": value },
		"set x by (!)": { "nan": 0, "inf": value },
		"set y by (!)": { "nan": 0, "inf": value },
		"turn (!) right": { "nan": 0, "inf": 0 },
		"turn (!) left": { "nan": 0, "inf": 0 },
		"point in direction (!)": { "nan": 0, "inf": 0 },
		"glide (!) secs to ()": { "nan": 0, "inf": 0 },
		"glide () secs to (!)": { "nan": 0, "inf": 0 },
		"glide () secs to x:(!) y:()": { "nan": 0, "inf": 0 },
		"glide () secs to x:() y:(!)": { "nan": 0, "inf": 0 },

		"say (!) for () seconds": { "nan": "NaN", "inf": "Infinitiv" },
		"say () for (!) seconds": { "nan": 0, "inf": 0 },
		"say (!)": { "nan": "NaN", "inf": "Infinitiv" },
		"think (!) for () seconds": { "nan": "NaN", "inf": "Infinitiv" },
		"think () for (!) seconds": { "nan": 0, "inf": 0 },
		"think (!)": { "nan": "NaN", "inf": "Infinitiv" },
		"switch costume to (!)": { "nan": 1, "inf": 1 },
		"change size by (!)": { "nan": 0, "inf": value },
		"set size to (!)": { "nan": 0, "inf": value }
		}
	
	# Prüfen, ob der Block in der Liste ist
	if block_behaviors.has(block):
		var behavior = block_behaviors[block]
		return correct_value(value, type, path, block, behavior["nan"], behavior["inf"])

	if type == "float":
		if typeof(value) == TYPE_BOOL:
			return float(1) if value else float(0)
		return float(str(value)) if str(value).is_valid_float else float(0)
			
	if type == "string":
		return str(value) if str(value) else " "

	if type == "bool":
		return true if str(value) == "true" or str(value) != "0" or str(value) != "" else false
static func correct_value(value, type, path, block, nan_default, inf_default):
	
	if str(value) == "NaN":
		print_warning(path, block, value, "NaN", nan_default)
		return nan_default

	if str(value) == "Infinity" or str(value) == "-Infinity":
		print_warning(path, block, value, "Infinity", inf_default)
		return inf_default

	if type == "float":
		if typeof(value) == TYPE_BOOL:
			return float(1) if value else float(0)
		return float(str(value)) if str(value).is_valid_float else float(0)

	if type == "string":
		return str(value)

	if type == "bool":
		return true if str(value) == "true" else false
static func print_not_existing(path, type, value):
	print("WARNING: In script '%s', the converted block '%s' received an value ('%s') that cannot be assigned." % [path, type, str(value)])
	print("	→ As per Scratch behavior, the block did nothing")
	help()

static func print_warning(path, type, value, issue, replacement):
	print("WARNING: In script '%s', the converted block '%s' received an invalid value ('%s')." % [path, type, str(value)])
	print("	→ As per Scratch behavior, '%s' has been replaced with '%s' to prevent errors." % [issue, str(replacement)])
	help()

static func print_unknown_error(path, type, value, replacement):
	print("ERROR: In script '%s', the converted block '%s' received an invalid value ('%s')." % [path, type, str(value)])
	print("	→ the problem was not recognized, but something is wrong. Scratch probably handled this differently than Godot")
	print(" → to avoid errors it was replaced with '%s'" % [str(replacement)])
	help()

static func help():
	print("	→ If this is intentional, you can ignore this warning.")
	print("	→ If this causes unexpected behavior, check the gd-script, check the source block in Scratch or reconvert the project.")
	print("	→ Need help? Join 'discord/empty' for support.")