class_name ScratchSettings
extends Resource

const CLOUD_HOST = "wss://clouddata.turbowarp.org"

enum ScreenDimensionsMode {
    PRESERVE,
    STRETCH,
    RESIZE,
}

enum CloudVariableMode {
    SERVER,
    CLIENT,
    IGNORE,
    ADVANCED,
}

enum HitboxStrategy {
    PIXEL,
    CONVEX_HULL,
    AABB,
}

@export_category("Runtime Options")
@export var infinite_clones: bool = false
@export var max_clones: int = 300
@export var close_window_when_project_stops: bool = false
@export var start_project_automatically: bool = false
@export var screen_dimensions: Vector2 = Vector2(480, 360)
@export var screen_dimension_mode: ScreenDimensionsMode = ScreenDimensionsMode.PRESERVE

@export_category("Player Options")
@export var show_green_flag: bool = true
@export var show_stop_button: bool = true
@export var background_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var stage_color: Color = Color.WHITE
@export var monitor_scale: float = 1.0
@export var accent_color: Color = Color(1.0, 0.3, 0.3, 1.0)
@export var variable_color: Color = Color(1, 0.5, 0.1, 1.0)
@export var list_color: Color = Color(1.0, 0.4, 1.0, 0.2)
@export var editable_lists: bool = true

@export_category("Collision & Hitbox")
@export var hitbox_strategy: HitboxStrategy = HitboxStrategy.PIXEL
@export var hitbox_detail: float = 2.0
@export var hitbox_max_polygons: int = 4

@export_category("Cloud Variables")
@export var cloud_variable_mode: CloudVariableMode = CloudVariableMode.SERVER
@export var cloud_variable_server_url: String = CLOUD_HOST
@export var project_id: String = ""
@export var advanced_cloud_variable_settings: Dictionary[String, CloudVariableMode] = {}
@export var cloud_sync_debounce_ms: int = 100

@export_category("Build & Conversion")
@export var scratch_scene_output_path: String = "res://scenes/scratch_converted/"
@export var delete_temporary_folders_after_conversion: bool = true
@export var log_level: ScratchLog.Level = ScratchLog.Level.WARN
@export var log_conversion_process: bool = false:
    get:
        return log_level == ScratchLog.Level.VERBOSE
    set(v):
        log_conversion_process = v
        log_level = ScratchLog.Level.VERBOSE if v else ScratchLog.Level.WARN
@export var continue_on_error: bool = false
@export var overwrite_existing_scenes: bool = false


func export_settings(path: String) -> Error:
    return ResourceSaver.save(self, path)


static func load_settings(path: String) -> ScratchSettings:
    ScratchLog.v("Loading settings from: " + path)
    if ResourceLoader.exists(path):
        var loaded = ResourceLoader.load(path)
        if loaded is ScratchSettings:
            return loaded

    return ScratchSettings.new()
