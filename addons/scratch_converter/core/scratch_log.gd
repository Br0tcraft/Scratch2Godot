class_name ScratchLog
extends RefCounted

enum Level {SILENT = 0, WARN = 1, VERBOSE = 2}
static var level: Level = Level.WARN

static func v(msg: String) -> void:
	if level >= Level.VERBOSE:
		print(msg)

static func w(msg: String) -> void:
	if level >= Level.WARN:
		push_warning(msg)

static func e(msg: String) -> void:
	push_error(msg)
