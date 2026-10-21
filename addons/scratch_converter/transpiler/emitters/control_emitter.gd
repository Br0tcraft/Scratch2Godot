class_name ControlEmitter
extends RefCounted

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "control_wait":
            var dur := ExpressionEmitter.emit(block.inputs.get("DURATION"), ctx)
            ctx.writer.line("await control.wait(ctx, S.num(%s))" % dur)
            ctx.writer.line("if ctx.cancelled(): return")

        "control_repeat":
            var times := ExpressionEmitter.emit(block.inputs.get("TIMES"), ctx)
            ctx.writer.line("for _i%s in int(round(S.num(%s))):" % ["" if ctx.writer._indent - 1 <= 0 else "_" + str(ctx.writer._indent - 1), times])
            ctx.writer.indent()
            _substack(block, "SUBSTACK", ctx)
            ctx.writer.line("if ctx.cancelled(): break")
            ctx.writer.line("await get_tree().process_frame")
            ctx.writer.dedent()

        "control_forever":
            ctx.writer.line("while not ctx.cancelled():")
            ctx.writer.indent()
            _substack(block, "SUBSTACK", ctx)
            ctx.writer.line("await get_tree().process_frame")
            ctx.writer.dedent()

        "control_repeat_until":
            var cond := ExpressionEmitter.emit(block.inputs.get("CONDITION"), ctx)
            ctx.writer.line("while not S.boolean(%s) and not ctx.cancelled():" % cond)
            ctx.writer.indent()
            _substack(block, "SUBSTACK", ctx)
            ctx.writer.line("await get_tree().process_frame")
            ctx.writer.dedent()

        "control_while":
            var cond := ExpressionEmitter.emit(block.inputs.get("CONDITION"), ctx)
            ctx.writer.line("while S.boolean(%s) and not ctx.cancelled():" % cond)
            ctx.writer.indent()
            _substack(block, "SUBSTACK", ctx)
            ctx.writer.line("await get_tree().process_frame")
            ctx.writer.dedent()

        "control_for_each":
            var vf = block.fields.get("VARIABLE")
            var var_ref := DataEmitter._var_ref(vf, ctx)
            var val := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("var _fe_max := int(S.num(%s))" % val)
            ctx.writer.line("for _fe_i in range(1, _fe_max + 1):")
            ctx.writer.indent()
            ctx.writer.line("%s = _fe_i" % var_ref)
            _substack(block, "SUBSTACK", ctx)
            ctx.writer.line("if ctx.cancelled(): break")
            ctx.writer.line("await get_tree().process_frame")
            ctx.writer.dedent()

        "control_if":
            var cond := ExpressionEmitter.emit(block.inputs.get("CONDITION"), ctx)
            ctx.writer.line("if S.boolean(%s):" % cond)
            ctx.writer.indent()
            _substack_or_pass(block, "SUBSTACK", ctx)
            ctx.writer.dedent()

        "control_if_else":
            var cond := ExpressionEmitter.emit(block.inputs.get("CONDITION"), ctx)
            ctx.writer.line("if S.boolean(%s):" % cond)
            ctx.writer.indent()
            _substack_or_pass(block, "SUBSTACK", ctx)
            ctx.writer.dedent()
            ctx.writer.line("else:")
            ctx.writer.indent()
            _substack_or_pass(block, "SUBSTACK2", ctx)
            ctx.writer.dedent()

        "control_wait_until":
            var cond := ExpressionEmitter.emit(block.inputs.get("CONDITION"), ctx)
            ctx.writer.line("await control.wait_until(ctx, func(): return S.boolean(%s))" % cond)
            ctx.writer.line("if ctx.cancelled(): return")

        "control_create_clone_of":
            var menu = block.inputs.get("CLONE_OPTION")
            var target_self := true
            var clone_target_name := ""
            if menu != null:
                var sub: ScratchBlockModel = ctx.sprite.scripts.get(menu.block_id)
                if sub and sub.opcode == "control_create_clone_of_menu":
                    var f = sub.fields.get("CLONE_OPTION")
                    if f != null and f.value != "_myself_":
                        target_self = false
                        clone_target_name = f.value
            if target_self:
                ctx.writer.line("control.create_clone_of(self)")
            else:
                ctx.writer.line("control.create_clone_of_named(\"%s\")" % EmitterHelpers.esc(clone_target_name))

        "control_delete_this_clone":
            ctx.writer.line("control.delete_this_clone()")
            ctx.writer.line("return")

        "control_stop":
            var opt := _field(block, "STOP_OPTION", "all")
            match opt:
                "this script":
                    ctx.writer.line("return")
                "other scripts in sprite", "other scripts in stage":
                    ctx.writer.line("ctx.sprite.stop_other_scripts(ctx)")
                _: # "all"
                    ctx.writer.line("ctx.sprite.get_scratch_project().stop_all_project_scripts()")
                    ctx.writer.line("return")

        "control_clear_counter":
            ctx.writer.line("control.clear_counter()")
        "control_incr_counter":
            ctx.writer.line("control.incr_counter()")

        "control_all_at_once":
            _substack_or_pass(block, "SUBSTACK", ctx)

        _:
            ctx.writer.line("# TODO control: " + block.opcode)

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "control_get_counter":
            return "control.get_counter()"
    return "0.0  # TODO control expr: " + block.opcode


static func _substack(block: ScratchBlockModel, name: String, ctx: EmitContext) -> void:
    var input: ScratchInputModel = block.inputs.get(name)
    if input == null or input.block_id.is_empty():
        return
    StatementEmitter.emit_chain(input.block_id, ctx)

static func _substack_or_pass(block: ScratchBlockModel, name: String, ctx: EmitContext) -> void:
    var input: ScratchInputModel = block.inputs.get(name)
    if input == null or input.block_id.is_empty():
        ctx.writer.line("pass")
        return
    StatementEmitter.emit_chain(input.block_id, ctx)