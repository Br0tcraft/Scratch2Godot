class_name MonitorManager
extends CanvasLayer

const DIR := "res://addons/scratch_converter/core/runtime/monitor/"
var variable_color := Color(1, 0.5, 0.1)
var list_color := Color(1, 0.4, 1, 0.2)
var editable_lists := true
var monitor_scale := 1.0
var _entries: Dictionary = {} # sb3 id -> entry dict
var _frame := 0

func _init() -> void:
	layer = 100
	name = "Monitors"

func add_variable(owner: ScratchSprite, id: String, gd: String, label: String, cfg: Dictionary) -> void:
	_register("var", owner, id, gd, label, cfg)

func add_list(owner: ScratchSprite, id: String, gd: String, label: String, cfg: Dictionary) -> void:
	_register("list", owner, id, gd, label, cfg)

func _register(kind, owner, id, gd, label, cfg) -> void:
	_entries[id] = {"kind": kind, "owner": weakref(owner), "gd": gd, "label": label,
		"cfg": cfg, "node": null, "last": null, "hash": 0}
	if cfg.get("visible", false): _show(id)

func set_visibility(id: String, v: bool) -> void:
	if not _entries.has(id): return
	var e: Dictionary = _entries[id]
	e.cfg["visible"] = v
	if v: _show(id)
	elif e.node: e.node.hide()

func _show(id: String) -> void:
	var e: Dictionary = _entries[id]
	if e.node == null:
		e.node = _build(e)
		add_child(e.node)
	e.node.show()
	e.last = null

func _build(e: Dictionary) -> Control:
	var cfg: Dictionary = e.cfg
	var n: Control
	if e.kind == "var":
		n = (load(DIR + "variable.tscn") as PackedScene).instantiate()
		n.variable_name = e.label
		n.mode = {"normal": 0, "large": 1, "slider": 2}.get(cfg.mode, 0)
		n.slider_min = cfg.min
		n.slider_max = cfg.max
		n.accent_color = variable_color
		n.value_committed.connect(func(v: float): _write_var(e, v))
		if cfg.has("width") and cfg.width > 0:
			n.custom_minimum_size = Vector2(cfg.width, cfg.height)
			n.size = Vector2(cfg.width, cfg.height)
	else:
		n = (load(DIR + "list.tscn") as PackedScene).instantiate()
		n.list_name = e.label
		n.accent_color = list_color
		n.editable = editable_lists
		n.item_edited.connect(func(i: int, t: String): _edit_item(e, i, t))
	n.position = Vector2(cfg.x, cfg.y) * monitor_scale
	n.scale = Vector2.ONE * monitor_scale
	return n

func _process(_d: float) -> void:
	_frame += 1
	for e in _entries.values():
		if e.node == null or not e.node.visible: continue
		var owner: ScratchSprite = e.owner.get_ref()
		if owner == null: continue
		var val = owner.get(e.gd)
		if e.kind == "var":
			if typeof(val) != typeof(e.last) or val != e.last:
				e.last = val
				e.node.variable_value = val
		elif _frame % 3 == 0:
			var h: int = (val as Array).hash()
			if h != e.hash:
				e.hash = h
				e.node.update_list(val)

func _write_var(e: Dictionary, v: float) -> void:
	var owner: ScratchSprite = e.owner.get_ref()
	if owner == null: return
	owner.set(e.gd, int(v) if e.cfg.get("discrete", true) else v)
	if e.cfg.has("cloud"): owner._cloud_sync(e.cfg.cloud)

func _edit_item(e: Dictionary, index: int, text: String) -> void:
	var owner: ScratchSprite = e.owner.get_ref()
	if owner:
		var arr: Array = owner.get(e.gd)
		if index >= 1 and index <= arr.size(): arr[index - 1] = text