class_name ExpressionEmitter
extends RefCounted

static func emit(input: ScratchInputModel, ctx: EmitContext) -> String:
    if input == null:
        return "0.0"
    match input.type:
        ScratchInputModel.InputType.VALUE:
            return literal(input.value)
        ScratchInputModel.InputType.VARIABLE:
            return _emit_var_ref(input.block_id, ctx)
        ScratchInputModel.InputType.LIST:
            return ctx.gd_list_name(input.block_id)
        ScratchInputModel.InputType.BLOCK_REF:
            var block: ScratchBlockModel = ctx.sprite.scripts.get(input.block_id)
            if block == null:
                return "0.0"
            return emit_block(block, ctx)
    return "0.0"

static func _emit_var_ref(sb3_id: String, ctx: EmitContext) -> String:
    if ctx.gd_local_var_names.has(sb3_id):
        return ctx.gd_local_var_names[sb3_id]
    if ctx.gd_global_var_names.has(sb3_id):
        if ctx.sprite == ctx.project.stage:
            return ctx.gd_global_var_names[sb3_id]
        return "stage." + ctx.gd_global_var_names[sb3_id]
    return "0.0  # unresolved var: " + sb3_id

static func emit_block(block: ScratchBlockModel, ctx: EmitContext) -> String:
    if block.opcode.begins_with("argument_reporter_"):
        var f = block.fields.get("VALUE")
        if f != null:
            return ProceduresEmitter._sanitize_arg_name(f.value)
        return "0.0"
    
    var prefix := block.opcode.split("_")[0]
    match prefix:
        "motion": return MotionEmitter.emit_expression(block, ctx)
        "looks": return LooksEmitter.emit_expression(block, ctx)
        "operator": return OperatorEmitter.emit_expression(block, ctx)
        "sensing": return SensingEmitter.emit_expression(block, ctx)
        "data": return DataEmitter.emit_expression(block, ctx)
        "control": return ControlEmitter.emit_expression(block, ctx)
        "sound": return SoundEmitter.emit_expression(block, ctx)
    return "0.0 "

static func literal(value: Variant) -> String:
    match typeof(value):
        TYPE_STRING:
            return "\"%s\"" % str(value).replace("\\", "\\\\").replace("\"", "\\\"")
        TYPE_FLOAT, TYPE_INT:
            return str(float(value))
        TYPE_BOOL:
            return "true" if value else "false"
        TYPE_NIL:
            return "null"
    return str(value)