class_name EventEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "event_broadcast":
            var bc_expr := _resolve_broadcast_input(block, "BROADCAST_INPUT", ctx)
            ctx.writer.line("if ctx.sprite.get_scratch_project(): ctx.sprite.get_scratch_project().broadcast(S.str(%s))" % bc_expr)
        "event_broadcastandwait":
            var bc_expr := _resolve_broadcast_input(block, "BROADCAST_INPUT", ctx)
            ctx.writer.line("await _event_broadcast_and_wait(ctx, S.str(%s))" % bc_expr)
        _:
            ctx.writer.line("# TODO event: " + block.opcode)

static func _resolve_broadcast_input(block: ScratchBlockModel, input_key: String, ctx: EmitContext) -> String:
    var inp = block.inputs.get(input_key)
    if inp == null:
        var f = block.fields.get("BROADCAST_OPTION")
        if f != null:
            return "\"%s\"" % EmitterHelpers.esc(f.value)
        return "\"\""
    if inp.type == ScratchInputModel.InputType.VALUE:
        return "\"%s\"" % EmitterHelpers.esc(str(inp.value))
    if inp.type == ScratchInputModel.InputType.BLOCK_REF:
        var sub: ScratchBlockModel = ctx.sprite.scripts.get(inp.block_id)
        if sub != null and sub.opcode in ["event_broadcast_menu", "event_broadcast_menu_button"]:
            var f = sub.fields.get("BROADCAST_OPTION")
            if f != null:
                return "\"%s\"" % EmitterHelpers.esc(f.value)
    return ExpressionEmitter.emit(inp, ctx)
