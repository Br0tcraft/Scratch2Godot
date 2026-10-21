class_name ScratchLayers
extends RefCounted

static func _is_stage(s: ScratchSprite) -> bool:
	return s.stage == null or s.stage == s

static func _floor_idx(s: ScratchSprite) -> int:
	return s.stage.get_index() + 1

static func _top_idx(s: ScratchSprite) -> int:
	var p := s.get_parent()
	for i in range(p.get_child_count() - 1, -1, -1):
		if p.get_child(i) is ScratchSprite:
			return i
	return s.get_index()

static func to_front(s: ScratchSprite) -> void:
	if _is_stage(s): return
	s.get_parent().move_child(s, _top_idx(s))

static func to_back(s: ScratchSprite) -> void:
	if _is_stage(s): return
	s.get_parent().move_child(s, _floor_idx(s))

static func shift(s: ScratchSprite, n: int) -> void:
	if _is_stage(s): return
	var t := clampi(s.get_index() + n, _floor_idx(s), _top_idx(s))
	s.get_parent().move_child(s, t)

static func place_behind(s: ScratchSprite, other: ScratchSprite) -> void:
	s.get_parent().move_child(s, other.get_index())