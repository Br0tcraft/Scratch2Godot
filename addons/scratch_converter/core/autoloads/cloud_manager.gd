class_name CloudManager
extends Node

var _project_id: String = ""
var _host: String = ""
var _default_mode: ScratchSettings.CloudVariableMode = ScratchSettings.CloudVariableMode.SERVER
var _advanced: Dictionary = {}

var _backend_server: CloudServerBackend = null
var _backend_storage: CloudStorageBackend = null

var _stage: ScratchSprite
var _dirty: Dictionary = {}
var _last_synced: Dictionary = {} # name -> String
var _last_flush := 0
var debounce_ms := 100

static func _key(n: String) -> String:
	return n.trim_prefix("☁").strip_edges()

func bind_stage(s: ScratchSprite) -> void:
	_stage = s

func mark_dirty(n: String) -> void:
	_dirty[n] = true

func configure(mode: ScratchSettings.CloudVariableMode, host: String,
		project_id: String, advanced: Dictionary) -> void:
	_project_id = project_id
	_host = host
	_default_mode = mode
	_advanced.clear()
	for k in advanced:
		_advanced[_key(str(k))] = advanced[k]

	match mode:
		ScratchSettings.CloudVariableMode.SERVER:
			_ensure_server()
		ScratchSettings.CloudVariableMode.CLIENT:
			_ensure_storage()
		ScratchSettings.CloudVariableMode.ADVANCED:
			_ensure_server()
			var needs_storage := false
			for v in _advanced.values():
				if v == ScratchSettings.CloudVariableMode.CLIENT:
					needs_storage = true
					break
			if needs_storage:
				_ensure_storage()

func _ensure_server() -> void:
	if _backend_server: return
	_backend_server = CloudServerBackend.new(_host, _project_id)
	_backend_server.name = "CloudServer"
	_backend_server.value_received.connect(_on_value_received.bind(ScratchSettings.CloudVariableMode.SERVER))
	add_child(_backend_server)
	_backend_server.start()

func _ensure_storage() -> void:
	if _backend_storage: return
	_backend_storage = CloudStorageBackend.acquire(_project_id)
	_backend_storage.value_received.connect(_on_value_received.bind(ScratchSettings.CloudVariableMode.CLIENT))

func _mode_for(var_name: String) -> ScratchSettings.CloudVariableMode:
	if _default_mode == ScratchSettings.CloudVariableMode.ADVANCED:
		return _advanced.get(_key(var_name), ScratchSettings.CloudVariableMode.SERVER)
	return _default_mode

func _process(_d: float) -> void:
	if _dirty.is_empty(): return
	if _stage == null:
		var parent := get_parent()
		if parent is ScratchProject:
			_stage = parent.get_stage()
	if _stage == null: return
	var now := Time.get_ticks_msec()
	if now - _last_flush < debounce_ms: return
	_last_flush = now
	for n in _dirty.keys():
		var s := S.str(_stage.read_cloud(n))
		if _last_synced.get(n, "") == s: continue
		_last_synced[n] = s
		match _mode_for(n):
			ScratchSettings.CloudVariableMode.SERVER:
				if _backend_server: _backend_server.send(n, s)
			ScratchSettings.CloudVariableMode.CLIENT:
				if _backend_storage: _backend_storage.send(n, s)
	_dirty.clear()

func _on_value_received(arg1: Variant, arg2: Variant, arg3: Variant = null) -> void:
	var source: int
	var name: String
	var value: String
	if arg1 is int:
		source = arg1
		name = str(arg2)
		value = str(arg3) if arg3 != null else ""
	else:
		name = str(arg1)
		value = str(arg2)
		source = int(arg3) if arg3 != null else ScratchSettings.CloudVariableMode.SERVER
	if _mode_for(name) != source: return
	_last_synced[name] = value
	if _stage: _stage._apply_cloud_value(name, value)

func cloud_set(var_name: String, _value: Variant = null) -> void:
	mark_dirty(var_name)