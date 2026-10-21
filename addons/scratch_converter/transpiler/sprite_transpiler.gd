class_name SpriteTranspiler
extends RefCounted

var _sprite: ScratchSpriteModel
var _project: ScratchProjectModel
var _settings: ScratchSettings
var _logger: ScratchLogger

var _slug: String
var _scene_path: String
var _script_path: String
var _sprite_dir: String


func setup(sprite: ScratchSpriteModel, project: ScratchProjectModel,
           settings: ScratchSettings, logger: ScratchLogger) -> void:
    _sprite = sprite
    _project = project
    _settings = settings
    _logger = logger

func get_scene_path() -> String:
    return _scene_path

func get_script_path() -> String:
    return _script_path


func transpile(output_dir: String) -> Error:
    _slug = _slugify(_sprite.sprite_name)
    _sprite_dir = output_dir.path_join("sprites")
    if _sprite == _project.stage:
        _sprite_dir = output_dir
        _slug = "stage"

    DirAccess.make_dir_recursive_absolute(_sprite_dir)

    _scene_path = _sprite_dir.path_join(_slug + ".tscn")
    _script_path = _sprite_dir.path_join(_slug + ".gd")

    var asset_map := _copy_assets(output_dir)
    if asset_map == null:
        return ERR_FILE_CANT_WRITE

    var script_src := _generate_script()
    if script_src.is_empty():
        return ERR_INVALID_DATA
    var werr := _write_text(_script_path, script_src)
    if werr != OK:
        return werr

    return _build_scene(asset_map)

func _copy_assets(output_dir: String) -> Dictionary:
    var src_dir := ScratchProjectModel.PROJECTS_DIR + _project._project_id
    var dst_dir := output_dir.path_join("assets").path_join(_slug)
    DirAccess.make_dir_recursive_absolute(dst_dir)

    var map := {}
    var all_assets: Array = []
    for c in _sprite.costumes:
        all_assets.append({"md5ext": c.md5ext, "name": c.name, "ext": c.dataFormat})
    for s in _sprite.sounds:
        all_assets.append({"md5ext": s.md5ext, "name": s.name, "ext": s.dataFormat})

    for asset in all_assets:
        var md5ext: String = asset.md5ext
        if md5ext.is_empty():
            continue
        var src_path := src_dir.path_join(md5ext)
        if not FileAccess.file_exists(src_path):
            _log("Missing asset: " + src_path)
            continue
        var dst_name := "%s.%s" % [_slugify(asset.name), asset.ext]
        var dst_path := dst_dir.path_join(dst_name)
        var bytes := FileAccess.get_file_as_bytes(src_path)
        var f := FileAccess.open(dst_path, FileAccess.WRITE)
        if f == null:
            return {}
        f.store_buffer(bytes)
        f.close()

        map[md5ext] = dst_path.replace("res://", "").simplify_path()
        map[md5ext] = "res://" + map[md5ext].trim_prefix("/")

    return map

func _save_texture(tex: Texture2D, dst_dir: String, base_name: String) -> String:
    var tex_path := dst_dir.path_join(base_name + "_tex.res")
    if not FileAccess.file_exists(tex_path):
        ResourceSaver.save(tex, tex_path)
    return tex_path

func _generate_script() -> String:
    var builder := ScriptBuilder.new()
    return builder.build(_sprite, _project)

func _load_script(path: String) -> Script:
    if not FileAccess.file_exists(path):
        return null
    var src := FileAccess.get_file_as_string(path)
    if src.is_empty():
        return null
    var gd := GDScript.new()
    gd.source_code = src
    if gd.reload() != OK or not gd.can_instantiate():
        push_error("Compile-Fehler in " + path)
        return null
    gd.resource_path = path
    if Engine.is_editor_hint():
        EditorInterface.get_resource_filesystem().update_file(path)
    return gd

func _build_scene(asset_map: Dictionary) -> Error:
    var inst := ScratchSprite.new()
    inst.name = _slug

    var sprite2d := Sprite2D.new()
    sprite2d.name = "Sprite2D"
    inst.add_child(sprite2d)
    sprite2d.owner = inst

    var audio_player := AudioStreamPlayer.new()
    audio_player.name = "AudioStreamPlayer"
    inst.add_child(audio_player)
    audio_player.owner = inst

    EditorInterface.get_resource_filesystem().update_file(_script_path)
    var script := load(_script_path)
    EditorInterface.get_resource_filesystem().update_file(_script_path)
    inst.set_script(script)
    if inst.get_script() != script:
        push_error("set_script ist nicht durchgegangen! Pfad: " + _script_path)
        return ERR_INVALID_DATA

    var costumes: Array[ScratchCostume] = []
    var project_src_dir := ScratchProjectModel.PROJECTS_DIR + _project._project_id
    var costume_dst_dir := _sprite_dir.path_join("assets").path_join(_slug)
    DirAccess.make_dir_recursive_absolute(costume_dst_dir)
    for c in _sprite.costumes:
        var res := ScratchCostume.new()
        res.name = c.name
        res.rotation_center = Vector2(c.rotationCenterX, c.rotationCenterY)
        res.bitmap_resolution = c.bitmapResolution

        var source_path := asset_map.get(c.md5ext, "")
        if source_path.is_empty():
            source_path = project_src_dir.path_join(c.md5ext)

        var tex := _load_texture_for(source_path, c)
        if tex == null:
            _log("Skipping costume texture (no importer): " + c.md5ext)
            continue

        var tex_path := _save_texture(tex, costume_dst_dir, c.md5ext.get_basename())
        var loaded_tex := load(tex_path) as Texture2D
        if loaded_tex == null:
            loaded_tex = tex
        res.texture = loaded_tex

        var polys := _load_or_build_hitbox(c, loaded_tex, costume_dst_dir)
        res.hitbox_polygons = polys
        res.hitbox_polygon = polys[0] if polys.size() > 0 else PackedVector2Array()
        costumes.append(res)
        ScratchLog.v("Costume added to sprite")
    if inst is ScratchSprite:
        inst.costumes = costumes
        inst.current_costume = _sprite.current_costume_index
    else:
        _log("Warning: instantiated node is not ScratchSprite, skipping costume assignment")

    var sounds: Array[ScratchSound] = []
    for s in _sprite.sounds:
        var res := ScratchSound.new()
        res.name = s.name
        var audio_path: String = asset_map.get(s.md5ext, "")
        if audio_path.is_empty():
            var alt_a := project_src_dir.path_join(s.md5ext)
            if FileAccess.file_exists(alt_a):
                audio_path = alt_a
        else:
            var stream := _load_audio(audio_path)
            if stream:
                res.stream = stream
            else:
                _log("Skipping audio (no importer): " + audio_path)
        sounds.append(res)
    if inst is ScratchSprite:
        inst.sounds = sounds
    else:
        _log("Warning: instantiated node is not ScratchSprite, skipping sounds assignment")

    if _sprite != _project.stage and inst is ScratchSprite:
        inst.position = Vector2(_sprite.x, -_sprite.y)
        inst.direction = _sprite.direction
        inst.rotation_style = _sprite.rotation_style
        inst.scratch_visible = _sprite.visible
        inst.scratch_size = _sprite.size / 100.0
        inst.scratch_volume = _sprite.volume / 100.0
        inst.draggable = _sprite.draggable


    var packed := PackedScene.new()
    var perr := packed.pack(inst)
    inst.free()
    if perr != OK:
        return perr

    if FileAccess.file_exists(_scene_path) and not _settings.overwrite_existing_scenes:
        _log("Scene exists, skipping (overwrite disabled): " + _scene_path)
        return OK

    var err := ResourceSaver.save(packed, _scene_path)
    if err == OK and Engine.is_editor_hint():
        EditorInterface.get_resource_filesystem().update_file(_scene_path)
    return err


func _write_text(path: String, content: String) -> Error:
    var f := FileAccess.open(path, FileAccess.WRITE)
    if f == null:
        return FileAccess.get_open_error()
    f.store_string(content)
    f.close()
    return OK

func _slugify(raw: String) -> String:
    var out := ""
    for ch in raw.to_lower():
        if (ch >= "a" and ch <= "z") or ch.is_valid_int() or ch == "_":
            out += ch
        elif ch == " " or ch == "-":
            out += "_"
    if out.is_empty():
        out = "unnamed"
    if out[0].is_valid_int():
        out = "_" + out
    return out

func _log(msg: String) -> void:
    if _settings.log_conversion_process and _logger:
        _logger.log(msg)

static func _load_texture_for(path: String, costume) -> Texture2D:
    if path.is_empty():
        return null
    var ext := path.get_extension().to_lower()
    if ext == "svg":
        var svg := FileAccess.get_file_as_string(path)
        if svg.is_empty():
            return null
        var img := Image.new()
        var err := img.load_svg_from_string(svg, 1.0)
        if err != OK:
            return null
        return ImageTexture.create_from_image(img)
    else:
        return load(path) as Texture2D


static func _load_audio(path: String) -> AudioStream:
    if path.is_empty():
        return null

    var loaded := load(path)
    if loaded is AudioStream:
        return loaded as AudioStream
    return null

func _load_or_build_hitbox(costume, tex: Texture2D, dst_dir: String) -> Array[PackedVector2Array]:
    var strat_name: String = ScratchSettings.HitboxStrategy.keys()[_settings.hitbox_strategy].to_lower()
    var path := dst_dir.path_join("%s_hitbox_%s_%.1f_%d.tres" % [
        costume.md5ext, strat_name, _settings.hitbox_detail, _settings.hitbox_max_polygons
    ])
    if FileAccess.file_exists(path):
        var cached := load(path)
        if cached is HitboxResource:
            if not cached.polygons.is_empty():
                return cached.polygons
            elif cached.polygon.size() >= 3:
                return [cached.polygon]

    if tex == null:
        return []
    var img := tex.get_image()
    if img == null:
        return []

    var rotation_center := Vector2(costume.rotationCenterX, costume.rotationCenterY)
    var result_polys: Array[PackedVector2Array] = []

    match _settings.hitbox_strategy:
        ScratchSettings.HitboxStrategy.AABB:
            var aabb := _aabb_from_image(img, rotation_center, costume.bitmapResolution)
            if aabb.size() >= 3:
                result_polys.append(aabb)
        ScratchSettings.HitboxStrategy.CONVEX_HULL:
            var hull := _convex_hull_from_image(img, rotation_center, costume.bitmapResolution, _settings.hitbox_detail)
            if hull.size() >= 3:
                result_polys.append(hull)
        ScratchSettings.HitboxStrategy.PIXEL:
            result_polys = _generate_hitbox_polygons(img, rotation_center,
                costume.bitmapResolution, _settings.hitbox_detail, _settings.hitbox_max_polygons)

    var res := HitboxResource.new()
    res.polygons = result_polys
    if result_polys.size() > 0:
        res.polygon = result_polys[0]
    ResourceSaver.save(res, path)
    return result_polys

static func _aabb_from_image(img: Image, rotation_center: Vector2,
                                     bitmap_res: float) -> PackedVector2Array:
    var w := img.get_width()
    var h := img.get_height()
    var min_x := w; var max_x := 0
    var min_y := h; var max_y := 0
    for y in h:
        for x in w:
            if img.get_pixel(x, y).a >= 0.1:
                min_x = min(min_x, x); max_x = max(max_x, x)
                min_y = min(min_y, y); max_y = max(max_y, y)
    if min_x > max_x or min_y > max_y:
        return PackedVector2Array()

    var scale := 1.0 / maxf(bitmap_res, 1.0)
    var rc_x := rotation_center.x * scale
    var rc_y := rotation_center.y * scale
    var x0 := float(min_x) * scale - rc_x
    var y0 := float(min_y) * scale - rc_y
    var x1 := (float(max_x) + 1.0) * scale - rc_x
    var y1 := (float(max_y) + 1.0) * scale - rc_y
    return PackedVector2Array([
        Vector2(x0, y0),
        Vector2(x1, y0),
        Vector2(x1, y1),
        Vector2(x0, y1),
    ])

static func _convex_hull_from_image(img: Image, rotation_center: Vector2,
        bitmap_res: float, detail: float = 2.0) -> PackedVector2Array:
    const ALPHA_THRESHOLD := 0.1
    img.decompress()
    if not img.detect_alpha():
        return _aabb_from_image(img, rotation_center, bitmap_res)

    var bm := BitMap.new()
    bm.create_from_image_alpha(img, ALPHA_THRESHOLD)
    var polys := bm.opaque_to_polygons(
        Rect2i(Vector2i.ZERO, img.get_size()), detail)
    if polys.is_empty():
        return _aabb_from_image(img, rotation_center, bitmap_res)

    var all_points := PackedVector2Array()
    for p in polys:
        all_points.append_array(p)

    var hull := Geometry2D.convex_hull(all_points)
    if hull.size() < 3:
        return _aabb_from_image(img, rotation_center, bitmap_res)

    var scale := 1.0 / maxf(bitmap_res, 1.0)
    var rc := rotation_center * scale
    var out := PackedVector2Array()
    out.resize(hull.size())
    for i in hull.size():
        out[i] = Vector2(hull[i].x * scale - rc.x, hull[i].y * scale - rc.y)
    return out

static func _generate_hitbox_polygons(img: Image, rotation_center: Vector2,
        bitmap_res: float, detail: float = 2.0, max_polys: int = 4) -> Array[PackedVector2Array]:
    const ALPHA_THRESHOLD := 0.1
    img.decompress()
    if not img.detect_alpha():
        var aabb := _aabb_from_image(img, rotation_center, bitmap_res)
        return [aabb] if aabb.size() >= 3 else []

    var bm := BitMap.new()
    bm.create_from_image_alpha(img, ALPHA_THRESHOLD)

    var polys := bm.opaque_to_polygons(
        Rect2i(Vector2i.ZERO, img.get_size()), detail)
    if polys.is_empty():
        return []

    var poly_areas: Array[Dictionary] = []
    var max_area := 0.0
    for p in polys:
        var a := absf(_poly_signed_area(p))
        if a > max_area:
            max_area = a
        poly_areas.append({"poly": p, "area": a})

    if max_area <= 0.0:
        return []

    var min_threshold := max_area * 0.02
    var filtered: Array[Dictionary] = []
    for item in poly_areas:
        if item.area >= min_threshold:
            filtered.append(item)

    filtered.sort_custom(func(a, b): return a.area > b.area)

    if max_polys > 0 and filtered.size() > max_polys:
        filtered = filtered.slice(0, max_polys)

    var scale := 1.0 / maxf(bitmap_res, 1.0)
    var rc := rotation_center * scale
    var result: Array[PackedVector2Array] = []

    for item in filtered:
        var p: PackedVector2Array = item.poly
        var out := PackedVector2Array()
        out.resize(p.size())
        for i in p.size():
            out[i] = Vector2(p[i].x * scale - rc.x, p[i].y * scale - rc.y)
        if out.size() >= 3:
            result.append(out)

    return result

static func _generate_hitbox_polygon(img: Image, rotation_center: Vector2,
        bitmap_res: float, detail: float = 2.0) -> PackedVector2Array:
    var polys := _generate_hitbox_polygons(img, rotation_center, bitmap_res, detail, 1)
    return polys[0] if polys.size() > 0 else PackedVector2Array()

static func _poly_signed_area(p: PackedVector2Array) -> float:
    var a := 0.0
    for i in p.size():
        var j := (i + 1) % p.size()
        a += p[i].x * p[j].y - p[j].x * p[i].y
    return a * 0.5