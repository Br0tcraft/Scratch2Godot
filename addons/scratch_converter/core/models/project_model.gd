class_name ScratchProjectModel
extends RefCounted

const PROJECTS_DIR = "res://addons/scratch_converter/projects/"

var name: String = ""

var stage: ScratchSpriteModel = null
var sprites: Array[ScratchSpriteModel] = []
var _monitors: Array[ScratchMonitorModel] = []

var _settings: ScratchSettings = null
var _project_id: String = ""

enum Error {
    OK,
    FILE_NOT_FOUND,
    INVALID_EXTENSION,
    INVALID_FILE_FORMAT,
    INVALID_FILE_CONTENT,
    INVALID_JSON_FILE,
    TOO_MANY_STAGES,
    INVALID_JSON_CONTENT,
    INVALID_JSON_STRUCTURE,
    INVALID_JSON_DATA,
}


func _init() -> void:
    _project_id = str(randf_range(100000, 999999))


func set_settings(settings: ScratchSettings) -> void:
    _settings = settings


func load(path: String) -> ScratchProjectModel.Error:
    var error := _cache_project(path, _project_id)
    if error != Error.OK:
        return error

    var project_dir := PROJECTS_DIR + _project_id
    var project_json_path := project_dir + "/project.json"
    error = load_project_json(project_json_path)
    if error != Error.OK:
        return error

    return Error.OK


func load_project_json(project_json_path: String) -> ScratchProjectModel.Error:
    var file := FileAccess.open(project_json_path, FileAccess.READ)
    if not file:
        return Error.INVALID_JSON_FILE

    var project_data := JSON.parse_string(file.get_as_text())
    if not project_data:
        return Error.INVALID_JSON_CONTENT

    ScratchLog.v("[PROJECT] Loading Sprites...")
    sprites = _load_sprites(project_data)
    if sprites.size() < 1:
        return Error.INVALID_JSON_STRUCTURE
        
    ScratchLog.v("[PROJECT] Loading Monitors...")
    _monitors = _load_monitors(project_data)
    return Error.OK


func _load_sprites(project_data: Dictionary) -> Array[ScratchSpriteModel]:
    var targets := project_data.get("targets", [])
    if targets is not Array or targets.size() < 1:
        return []

    var new_sprites: Array[ScratchSpriteModel] = []
    for target in targets:
        var sprite := ScratchSpriteModel.new()
        sprite.load_from_dict(target)
        if sprite.is_stage:
            stage = sprite # overwrite stage if multiple stages are found (ToDo: Thats definitely not how it should be done, but for now it works)
            continue

        new_sprites.append(sprite)

    return new_sprites


func _load_monitors(project_data: Dictionary) -> Array[ScratchMonitorModel]:
    var monitors_list = project_data.get("monitors")
    if monitors_list is not Array:
        return []

    var scratch_monitors: Array[ScratchMonitorModel] = []
    for monitor_dict in monitors_list:
        if monitor_dict is not Dictionary:
            continue
            
        var scratch_monitor := ScratchMonitorModel.new()
        scratch_monitor.load_from_dict(monitor_dict)
        scratch_monitors.append(scratch_monitor)
        
    return scratch_monitors


func _cache_project(path: String, project_id: String) -> ScratchProjectModel.Error:
    if not path.ends_with(".sb3"):
        return Error.INVALID_EXTENSION
    
    if not FileAccess.file_exists(path):
        return Error.FILE_NOT_FOUND
    
    var sb3 := ZIPReader.new()
    var readerErr := sb3.open(path)
    if readerErr != OK:
        return Error.INVALID_FILE_FORMAT
    
    var project_dir := PROJECTS_DIR + project_id
    if not DirAccess.dir_exists_absolute(project_dir):
        DirAccess.make_dir_absolute(project_dir)
        
    var file_list := sb3.get_files()
    for file in file_list:
        if file.ends_with("/"):
            DirAccess.make_dir_recursive_absolute(project_dir + "/" + file)
            continue

        var file_path := project_dir + "/" + file
        var base_dir := file_path.get_base_dir()
        if not DirAccess.dir_exists_absolute(base_dir):
            DirAccess.make_dir_recursive_absolute(base_dir)

        var file_data := sb3.read_file(file)
        var new_file := FileAccess.open(file_path, FileAccess.WRITE)
        if not new_file:
            return Error.INVALID_FILE_CONTENT

        new_file.store_buffer(file_data)
        new_file.close()

    sb3.close()
    if not FileAccess.file_exists(PROJECTS_DIR + ".gdignore"):
        var file := FileAccess.open(PROJECTS_DIR + ".gdignore", FileAccess.WRITE)
        file.close()


    return Error.OK

func find_monitor(id: String) -> ScratchMonitorModel:
    for m in _monitors:
        if m._id == id: return m
    return null
