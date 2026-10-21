class_name ProjectTranspiler
extends RefCounted

var settings: ScratchSettings
var project: ScratchProjectModel
var logger: ScratchLogger

var _output_dir: String
var _errors: Array[String] = []

func set_settings(s: ScratchSettings) -> void:
    settings = s

func set_project(p: ScratchProjectModel) -> void:
    project = p


func transpile() -> Error:
    if not logger:
        logger = ScratchLogger.new()

    ScratchLog.level = settings.log_level
    _errors.clear()
    _output_dir = settings.scratch_scene_output_path.path_join(project.name + "/").trim_suffix("/")

    _log("Start transpiling '%s'" % project.name)
    _log("Output: " + _output_dir)

    var err := _ensure_output_dir()
    if err != OK:
        return err

    var stage_transpiler := SpriteTranspiler.new()
    stage_transpiler.setup(project.stage, project, settings, logger)
    err = stage_transpiler.transpile(_output_dir)
    if err != OK:
        _errors.append("Stage: " + error_string(err))
        if not _continue_on_error():
            return err

    var sprite_scene_paths: Array[String] = []
    ScratchLog.v("Sprite Size: %s" % project.sprites.size())
    var ordered: Array[ScratchSpriteModel] = project.sprites.duplicate()
    ordered.sort_custom(func(a, b): return a.layer_order < b.layer_order)
    for sprite in ordered:
        ScratchLog.v("Transpiling Sprite: %s" % sprite.sprite_name)
        var t := SpriteTranspiler.new()
        t.setup(sprite, project, settings, logger)
        err = t.transpile(_output_dir)
        ScratchLog.v("Sprite Transpiled: %s" % sprite.sprite_name)
        if err != OK:
            _errors.append(sprite.sprite_name + ": " + error_string(err))
            if not _continue_on_error():
                return err
        else:
            ScratchLog.v("Sprite Added to Sprite Scene Paths: %s" % sprite.sprite_name)
            sprite_scene_paths.append(t.get_scene_path())

    err = _build_root_scene(stage_transpiler.get_scene_path(), sprite_scene_paths)
    if err != OK:
        _errors.append("Root scene: " + error_string(err))
        if not _continue_on_error():
            return err

    if not _errors.is_empty():
        _log("Transpilation finished with %d error(s)" % _errors.size())
        for e in _errors:
            _log("\t- " + e)
        return ERR_INVALID_DATA

    _log("Transpilation complete.")
    if settings.delete_temporary_folders_after_conversion:
        _cleanup_temp_project()
    return OK


func _build_root_scene(stage_path: String, sprite_paths: Array[String]) -> Error:
    var root := Control.new()
    root.name = _sanitize_node_name(project.name)
    
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.size_flags_vertical = Control.SIZE_EXPAND_FILL

    var script: Script = load("res://addons/scratch_converter/core/runtime/scratch_project.gd")
    root.set_script(script)

    root.set("start_project_automatically", settings.start_project_automatically)
    root.set("close_window_when_project_stops", settings.close_window_when_project_stops)
    root.set("infinite_clones", settings.infinite_clones)
    root.set("show_green_flag", settings.show_green_flag)
    root.set("show_stop_button", settings.show_stop_button)
    root.set("background_color", settings.background_color)
    root.set("accent_color", settings.accent_color)
    root.set("variable_color", settings.variable_color)
    root.set("list_color", settings.list_color)
    root.set("editable_lists", settings.editable_lists)
    root.set("cloud_variable_mode", settings.cloud_variable_mode)
    root.set("cloud_variable_server_url", settings.cloud_variable_server_url)
    root.set("project_id", settings.project_id)
    root.set("advanced_cloud_variable_settings", settings.advanced_cloud_variable_settings)
    root.set("cloud_sync_debounce_ms", settings.cloud_sync_debounce_ms)
    root.set("screen_dimensions", settings.screen_dimensions)
    root.set("screen_dimension_mode", settings.screen_dimension_mode)
    root.set("stage_color", settings.stage_color)
    root.set("monitor_scale", settings.monitor_scale)
    root.set("log_level", settings.log_level)
    root.set("max_clones", settings.max_clones)

    var bg := ColorRect.new()
    bg.name = "Background"
    bg.color = settings.background_color
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(bg)
    bg.owner = root

    var vbox := VBoxContainer.new()
    vbox.name = "VBoxContainer"
    vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    vbox.add_theme_constant_override("separation", 0)
    root.add_child(vbox)
    vbox.owner = root

    var has_taskbar := settings.show_green_flag or settings.show_stop_button
    if has_taskbar:
        var taskbar := PanelContainer.new()
        taskbar.name = "Taskbar"
        vbox.add_child(taskbar)
        taskbar.owner = root

        var controls := HBoxContainer.new()
        controls.name = "Controls"
        controls.add_theme_constant_override("separation", 8)
        taskbar.add_child(controls)
        controls.owner = root

        if settings.show_green_flag:
            var btn_flag := Button.new()
            btn_flag.name = "GreenFlagButton"
            btn_flag.text = "Flag"
            controls.add_child(btn_flag)
            btn_flag.owner = root

        if settings.show_stop_button:
            var btn_stop := Button.new()
            btn_stop.name = "StopButton"
            btn_stop.text = "Stop"
            controls.add_child(btn_stop)
            btn_stop.owner = root

    var viewport_parent: Node = vbox
    if settings.screen_dimension_mode == ScratchSettings.ScreenDimensionsMode.PRESERVE:
        var aspect_container := AspectRatioContainer.new()
        aspect_container.name = "AspectRatioContainer"
        if settings.screen_dimensions.y > 0:
            aspect_container.ratio = settings.screen_dimensions.x / settings.screen_dimensions.y
        else:
            aspect_container.ratio = 4.0 / 3.0
        aspect_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        aspect_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        aspect_container.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
        aspect_container.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
        vbox.add_child(aspect_container)
        aspect_container.owner = root
        viewport_parent = aspect_container

    var color_rect := ColorRect.new()
    color_rect.name = "ColorRect"
    color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
    color_rect.color = settings.stage_color
    viewport_parent.add_child(color_rect)
    color_rect.owner = root
    viewport_parent = color_rect

    var vp_container := SubViewportContainer.new()
    vp_container.name = "ViewportContainer"
    vp_container.stretch = true
    vp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vp_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vp_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    viewport_parent.add_child(vp_container)
    vp_container.owner = root

    var sub_viewport := SubViewport.new()
    sub_viewport.name = "SubViewport"
    
    var dimensions := Vector2i(settings.screen_dimensions)
    sub_viewport.size = dimensions
    if settings.screen_dimension_mode == ScratchSettings.ScreenDimensionsMode.RESIZE:
        sub_viewport.size_2d_override_stretch = false
    else:
        sub_viewport.size_2d_override = dimensions
        sub_viewport.size_2d_override_stretch = true
    sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    sub_viewport.transparent_bg = true
    sub_viewport.physics_object_picking = true
    vp_container.add_child(sub_viewport)
    sub_viewport.owner = root

    var camera := Camera2D.new()
    camera.name = "Camera2D"
    camera.position = Vector2.ZERO
    sub_viewport.add_child(camera)
    camera.owner = root

    var stage_scene := _load_scene_robust(stage_path)
    if stage_scene == null:
        _errors.append("Failed to load stage scene: " + stage_path)
        return ERR_FILE_CANT_READ
    var stage_instance := stage_scene.instantiate()
    stage_instance.name = "Stage"
    sub_viewport.add_child(stage_instance)
    stage_instance.owner = root
    
    var used_instance_names: Dictionary = {}
    for path in sprite_paths:
        var scene := _load_scene_robust(path)
        if scene == null:
            _errors.append("Failed to load sprite scene: " + path)
            if not _continue_on_error():
                return ERR_FILE_CANT_READ
            continue
        var inst := scene.instantiate()
        var base_name := path.get_file().get_basename()
        var instance_name := base_name
        var counter := 0
        while used_instance_names.has(instance_name):
            counter += 1
            instance_name = "%s_%d" % [base_name, counter]
        used_instance_names[instance_name] = true
        inst.name = instance_name
        sub_viewport.add_child(inst)
        inst.owner = root


    _log("Logging Node Tree:")
    if settings.log_conversion_process:
        root.print_tree()

    var out_path := _output_dir.path_join(project.name + ".tscn")
    _log("Saving Project to " + out_path)
    var packed := PackedScene.new()
    packed.pack(root)
    root.free()
    var save_err := ResourceSaver.save(packed, out_path)
    if save_err == OK and Engine.is_editor_hint():
        EditorInterface.get_resource_filesystem().update_file(out_path)
    return save_err


func _load_scene_robust(path: String) -> PackedScene:
    if path.is_empty() or not ResourceLoader.exists(path):
        push_error("Scene path missing or not yet importable: " + path)
        return null
    if Engine.is_editor_hint():
        EditorInterface.get_resource_filesystem().update_file(path)
    var res := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
    return res as PackedScene

func _ensure_output_dir() -> Error:
    if not DirAccess.dir_exists_absolute(_output_dir):
        var e := DirAccess.make_dir_recursive_absolute(_output_dir)
        if e != OK:
            _log("Cannot create output dir: " + error_string(e))
            return e
    return OK

func _continue_on_error() -> bool:
    return settings.continue_on_error

func _cleanup_temp_project() -> void:
    var temp_dir := ScratchProjectModel.PROJECTS_DIR + project._project_id
    if DirAccess.dir_exists_absolute(temp_dir):
        _log("Cleaning up temp: " + temp_dir)
        _remove_recursive(temp_dir)

func _remove_recursive(path: String) -> void:
    var dir := DirAccess.open(path)
    if dir == null:
        return
    dir.list_dir_begin()
    var name := dir.get_next()
    while name != "":
        var full := path.path_join(name)
        if dir.current_is_dir():
            _remove_recursive(full)
        else:
            DirAccess.remove_absolute(full)
        name = dir.get_next()
    dir.list_dir_end()
    DirAccess.remove_absolute(path)

func _sanitize_node_name(raw: String) -> String:
    var out := ""
    for ch in raw:
        if ch.is_valid_identifier() or ch == "_":
            out += ch
        else:
            out += "_"
    if out.is_empty():
        out = "Unnamed"
    return out

func _log(msg: String) -> void:
    ScratchLog.v(msg)
    if logger:
        logger.log(msg)