# ============================================================
#  Scratch2Godot - Standard Block Behavior Helper
#  ------------------------------------------------------------
#  This script emulates the value correction logic for various
#  Scratch blocks during runtime to match expected behavior
#  (e.g. handling of NaN, Infinity, type correction).
#
#  Symbols:
#    - (!) → Numerical or text input
#    - <>  → Boolean input
#    - []  → Fixed dropdown (value cannot be changed at runtime)
#    - ()  → Editable input field (can receive variables or custom values)
#    - {}  → Code blocks (if, repeat, etc.)
#
#  Author : Br0tcraft
#  Part of: Scratch2Godot
#
# Copyright (c) 2025 Br0tcraft
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# provided to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# License for games using this extension:
# - You are free to share and remix the game created with this extension.
# - Attribution must be given if the source code is shared.
# - If you distribute the source code, it must include proper credit to the 
#   original creators and translation contributors. (I would recommend to
#   just leave this note in this file)
# ===============================================================================
class_name correctur extends Node

static func ms(value, type, path, block):
	var block_behaviors = {
		"move steps (!)": { "nan": 0, "inf": value },
		"move [up/down] (!) steps": { "nan": 0, "inf": value },
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
		"set size to (!)": { "nan": 0, "inf": value },
		"go (forward/backward) (!) layers": { "nan": 0, "inf": -1 },
		"set stretch to x: (!) y: ()": { "nan": 0, "inf": 0 },
		"set stretch to x: () y: (!)": { "nan": 0, "inf": 0 },

		"wait (!) secs": { "nan": 0, "inf": value },
		"wait (!) secs or until true <>": { "nan": 0, "inf": value },
		"repeat (!) {}": { "nan": false, "inf": true },
		"repeat until <!>: {}": { "nan": false, "inf": true },
		"repeat while <!>: {}": { "nan": false, "inf": true },
		"if <!> then: {}": { "nan": false, "inf": true },
		"if <!> then: {} else: {}": { "nan": false, "inf": true },

		"broadcast (!)": { "nan": "NaN", "inf": "Infinitiv" },
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