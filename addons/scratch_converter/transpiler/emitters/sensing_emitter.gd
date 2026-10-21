class_name SensingEmitter
extends RefCounted

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "sensing_touchingobject":
            var target := _resolve_menu(block, "TOUCHINGOBJECTMENU", "TOUCHINGOBJECTMENU", ctx)
            return "sensing.touching(%s)" % target
        "sensing_touchingcolor":
            var color_expr := ExpressionEmitter.emit(block.inputs.get("COLOR"), ctx)
            return "sensing.touching_color(Color(%s))" % _color_from_scratch_literal(block, "COLOR", color_expr)
        "sensing_coloristouchingcolor":
            var c1 := ExpressionEmitter.emit(block.inputs.get("COLOR"), ctx)
            var c2 := ExpressionEmitter.emit(block.inputs.get("COLOR2"), ctx)
            return "sensing.color_is_touching_color(Color(%s), Color(%s))" % [
                _color_from_scratch_literal(block, "COLOR", c1),
                _color_from_scratch_literal(block, "COLOR2", c2)
            ]
        "sensing_distanceto":
            var target := _resolve_menu(block, "DISTANCETOMENU", "DISTANCETOMENU", ctx)
            return "sensing.distance_to(%s)" % target
        "sensing_keypressed":
            var k := _resolve_key_option(block, ctx)
            return "sensing.key_pressed(\"%s\")" % EmitterHelpers.esc(k)
        "sensing_mousedown": return "sensing.mouse_down()"
        "sensing_mousex": return "sensing.mouse_x()"
        "sensing_mousey": return "sensing.mouse_y()"
        "sensing_loudness": return "0.0" # TODO: Implement sensing.loudness() in runtime
        "sensing_timer": return "sensing.timer()"
        "sensing_answer": return "sensing.answer()"
        "sensing_of":
            var prop := _field(block, "PROPERTY", "")
            var obj_name := _field(block, "OBJECT", "_stage_")
            var direct := _try_resolve_of_direct(prop, obj_name, ctx)
            if direct != "":
                return direct
            return "sensing.of(\"%s\", \"%s\")" % [EmitterHelpers.esc(prop), EmitterHelpers.esc(obj_name)]
        "sensing_current":
            var u := _field(block, "CURRENTMENU", "year").strip_edges().to_lower().replace(" ", "").replace("_", "").replace("-", "")
            return "sensing.current(\"%s\")" % u
        "sensing_dayssince2000": return "sensing.days_since_2000()"
        "sensing_username": return "sensing.username()"
        "sensing_loud": return "(sensing.loudness() > 10.0)"
        "sensing_online": return "sensing.online()"
        "sensing_userid": return "0.0" # legacy no-op
    push_warning("Unresolved sensing expression: " + block.opcode)
    return "0.0"

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "sensing_askandwait":
            var m := ExpressionEmitter.emit(block.inputs.get("QUESTION"), ctx)
            ctx.writer.line("await sensing.ask_and_wait(ctx, S.str(%s))" % m)
        "sensing_resettimer":
            ctx.writer.line("sensing.reset_timer()")
        "sensing_setdragmode":
            var m := _field(block, "DRAG_MODE", "not draggable")
            ctx.writer.line("draggable = %s" % ("true" if m == "draggable" else "false"))
        _:
            ctx.writer.line("# TODO sensing: " + block.opcode)

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val


static func _resolve_menu(block: ScratchBlockModel, input_key: String, field_key: String, ctx: EmitContext) -> String:
    var menu_input = block.inputs.get(input_key)
    if menu_input == null:
        return "\"_mouse_\""
    if menu_input.type == ScratchInputModel.InputType.VALUE:
        return "\"%s\"" % EmitterHelpers.esc(str(menu_input.value))
    var sub: ScratchBlockModel = ctx.sprite.scripts.get(menu_input.block_id)
    if sub != null:
        var f = sub.fields.get(field_key)
        if f != null:
            return "\"%s\"" % EmitterHelpers.esc(f.value)
    return "S.str(%s)" % ExpressionEmitter.emit(menu_input, ctx)

static func _resolve_key_option(block: ScratchBlockModel, ctx: EmitContext) -> String:
    var ki = block.inputs.get("KEY_OPTION")
    if ki == null:
        return "space"
    if ki.type == ScratchInputModel.InputType.VALUE:
        return str(ki.value)
    var sub: ScratchBlockModel = ctx.sprite.scripts.get(ki.block_id)
    if sub != null and sub.opcode == "sensing_keyoptions":
        var f = sub.fields.get("KEY_OPTION")
        if f != null:
            return f.value
    return "space"

static func _try_resolve_of_direct(prop: String, obj_name: String, ctx: EmitContext) -> String:
    var is_stage := (obj_name == "_stage_" or obj_name == "Stage")
    var is_self := (obj_name == ctx.sprite.sprite_name)

    if is_self and not is_stage:
        match prop:
            "x position": return "motion.x_position()"
            "y position": return "motion.y_position()"
            "direction": return "motion.get_direction()"
            "size": return "looks.get_size()"
            "costume #", "costume number": return "looks.costume_number()"
            "costume name": return "looks.costume_name()"
            "volume": return "scratch_volume * 100.0"

    if is_stage:
        match prop:
            "backdrop #", "backdrop number", "background #":
                return "stage.looks.costume_number()"
            "backdrop name":
                return "stage.looks.costume_name()"
            "volume":
                return "stage.scratch_volume * 100.0"

    if is_self:
        for v in ctx.sprite.variables:
            if v.name == prop:
                return ctx.gd_var_name(v.id)
    if is_stage:
        for v in ctx.project.stage.variables:
            if v.name == prop:
                var gd := ctx.gd_var_name(v.id)
                if ctx.sprite != ctx.project.stage:
                    return "stage." + gd
                return gd
    return ""

static func _color_from_scratch_literal(block: ScratchBlockModel, input_key: String, fallback: String) -> String:
    var inp = block.inputs.get(input_key)
    if inp == null:
        return fallback
    if inp.type != ScratchInputModel.InputType.VALUE:
        return fallback
    var val = inp.value
    if val is float or val is int:
        var iv := int(val)
        var r := ((iv >> 16) & 0xFF) / 255.0
        var g := ((iv >> 8) & 0xFF) / 255.0
        var b := (iv & 0xFF) / 255.0
        return "%.6f, %.6f, %.6f, 1.0" % [r, g, b]
    if val is String:
        var s := str(val).strip_edges()
        if s.begins_with("#") and s.length() == 7:
            var r := s.substr(1, 2).hex_to_int() / 255.0
            var g := s.substr(3, 2).hex_to_int() / 255.0
            var b := s.substr(5, 2).hex_to_int() / 255.0
            return "%.6f, %.6f, %.6f, 1.0" % [r, g, b]
    return fallback