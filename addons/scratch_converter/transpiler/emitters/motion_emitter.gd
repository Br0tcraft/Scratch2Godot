class_name MotionEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "motion_movesteps":
            var steps := ExpressionEmitter.emit(block.inputs.get("STEPS"), ctx)
            ctx.writer.line("motion.move_steps(S.num(%s))" % steps)
        "motion_turnright":
            var d := ExpressionEmitter.emit(block.inputs.get("DEGREES"), ctx)
            ctx.writer.line("motion.turn_right(S.num(%s))" % d)
        "motion_turnleft":
            var d := ExpressionEmitter.emit(block.inputs.get("DEGREES"), ctx)
            ctx.writer.line("motion.turn_left(S.num(%s))" % d)

        "motion_goto":
            var to_str := _resolve_goto_menu(block, "TO", ctx)
            ctx.writer.line("motion.go_to(%s)" % to_str)
        "motion_gotoxy":
            var x := ExpressionEmitter.emit(block.inputs.get("X"), ctx)
            var y := ExpressionEmitter.emit(block.inputs.get("Y"), ctx)
            ctx.writer.line("motion.go_to_xy(S.num(%s), S.num(%s))" % [x, y])
        "motion_glidesecstoxy":
            var s := ExpressionEmitter.emit(block.inputs.get("SECS"), ctx)
            var x := ExpressionEmitter.emit(block.inputs.get("X"), ctx)
            var y := ExpressionEmitter.emit(block.inputs.get("Y"), ctx)
            ctx.writer.line("await motion.glide_to_xy(ctx, S.num(%s), S.num(%s), S.num(%s))" % [x, y, s])
        "motion_glideto":
            var s := ExpressionEmitter.emit(block.inputs.get("SECS"), ctx)
            var to_str := _resolve_goto_menu(block, "TO", ctx)
            ctx.writer.line("await motion.glide_to(ctx, S.num(%s), %s)" % [s, to_str])

        "motion_setx":
            var x := ExpressionEmitter.emit(block.inputs.get("X"), ctx)
            ctx.writer.line("motion.set_x(S.num(%s))" % x)
        "motion_sety":
            var y := ExpressionEmitter.emit(block.inputs.get("Y"), ctx)
            ctx.writer.line("motion.set_y(S.num(%s))" % y)
        "motion_changexby":
            var dx := ExpressionEmitter.emit(block.inputs.get("DX"), ctx)
            ctx.writer.line("motion.change_x(S.num(%s))" % dx)
        "motion_changeyby":
            var dy := ExpressionEmitter.emit(block.inputs.get("DY"), ctx)
            ctx.writer.line("motion.change_y(S.num(%s))" % dy)

        "motion_pointindirection":
            var d := ExpressionEmitter.emit(block.inputs.get("DIRECTION"), ctx)
            ctx.writer.line("motion.point_in_direction(S.num(%s))" % d)
        "motion_pointtowards":
            _emit_point_towards(block, ctx)

        "motion_ifonedgebounce":
            ctx.writer.line("motion.if_on_edge_bounce()")

        "motion_setrotationstyle":
            var style := _field(block, "STYLE", "all around")
            match style:
                "all around":
                    ctx.writer.line("motion.set_rotation_style(ScratchSprite.RotationStyle.ALL_AROUND)")
                "left-right":
                    ctx.writer.line("motion.set_rotation_style(ScratchSprite.RotationStyle.LEFT_RIGHT)")
                "don't rotate":
                    ctx.writer.line("motion.set_rotation_style(ScratchSprite.RotationStyle.DONT_ROTATE)")
                _:
                    ctx.writer.line("# unknown rotation style: %s" % style)

        "motion_scroll_right", "motion_scroll_up", "motion_align_scene", \
        "motion_xscroll", "motion_yscroll":
            ctx.writer.line("pass")

        _:
            ctx.writer.line("# TODO motion: " + block.opcode)

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "motion_xposition": return "motion.x_position()"
        "motion_yposition": return "motion.y_position()"
        "motion_direction": return "motion.get_direction()"
    push_warning("Unresolved motion expression: " + block.opcode)
    return "0.0"


static func _emit_point_towards(block: ScratchBlockModel, ctx: EmitContext) -> void:
    var menu_input = block.inputs.get("TOWARDS")
    if menu_input == null:
        ctx.writer.line("motion.point_towards(\"_mouse_\")")
        return
    var sub: ScratchBlockModel = ctx.sprite.scripts.get(menu_input.block_id) \
        if menu_input.type == ScratchInputModel.InputType.BLOCK_REF else null
    var target_val := "_mouse_"
    if sub != null:
        var f = sub.fields.get("TOWARDS")
        if f != null: target_val = f.value

    if target_val == "_mouse_":
        ctx.writer.line("motion.point_towards_mouse()")
    elif target_val == "_random_":
        ctx.writer.line("motion.point_in_direction(randi_range(-179, 180))")
    else:
        ctx.writer.line("motion.point_towards(\"%s\")" % EmitterHelpers.esc(target_val))

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val

static func _resolve_goto_menu(block: ScratchBlockModel, input_key: String, ctx: EmitContext) -> String:
    var menu_input = block.inputs.get(input_key)
    if menu_input == null:
        return "\"_mouse_\""
    if menu_input.type == ScratchInputModel.InputType.VALUE:
        return "\"%s\"" % EmitterHelpers.esc(str(menu_input.value))
    var sub: ScratchBlockModel = ctx.sprite.scripts.get(menu_input.block_id)
    if sub == null:
        return "\"_mouse_\""
    var f = sub.fields.get("TO")
    if f == null:
        return "\"_mouse_\""
    return "\"%s\"" % EmitterHelpers.esc(f.value)