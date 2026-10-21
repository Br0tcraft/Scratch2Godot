class_name CodeWriter
extends RefCounted

const INDENT := "\t"

var _lines: PackedStringArray = []
var _indent: int = 0

func line(text: String = "") -> void:
    if text.is_empty():
        _lines.append("")
    else:
        _lines.append(INDENT.repeat(_indent) + text)

func indent() -> void: _indent += 1
func dedent() -> void: _indent = max(0, _indent - 1)

func is_empty() -> bool: return _lines.is_empty()
func get_text() -> String: return "\n".join(_lines) + "\n"