class_name CloudStorageBackend
extends CloudBackend

# project_id -> WeakRef[CloudStorageBackend]
static var _shared: Dictionary = {}

var _project_id: String
var _file_path: String
var _data: Dictionary = {}

static func acquire(project_id: String) -> CloudStorageBackend:
	var b: CloudStorageBackend = null
	if _shared.has(project_id):
		b = _shared[project_id].get_ref()
	if b == null:
		b = CloudStorageBackend.new(project_id)
		_shared[project_id] = weakref(b)
	b._reload()
	return b

func _init(project_id: String = "") -> void:
	_project_id = project_id
	_file_path = "user://scratch_cloud_%s.json" % project_id

func start() -> void:
	pass

func _reload() -> void:
	_data.clear()
	if FileAccess.file_exists(_file_path):
		var f := FileAccess.open(_file_path, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_data = parsed
	for name in _data:
		value_received.emit.call_deferred(name, str(_data[name]))

func send(name: String, value: String) -> void:
	_data[name] = value
	_save()

func _save() -> void:
	var f := FileAccess.open(_file_path, FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify(_data))