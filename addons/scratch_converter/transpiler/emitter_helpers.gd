class_name EmitterHelpers
extends RefCounted

static func field(block: ScratchBlockModel, key: String, default_val: String = "") -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val

static func resolve_menu(
    block: ScratchBlockModel, input_key: String,
    shadow_opcodes: Array, shadow_field: String,
    ctx: EmitContext
) -> String:
    var inp = block.inputs.get(input_key)
    if inp == null:
        return "\"\""
    if inp.type == ScratchInputModel.InputType.VALUE:
        return "\"%s\"" % esc(str(inp.value))
    if inp.type == ScratchInputModel.InputType.BLOCK_REF:
        var sub: ScratchBlockModel = ctx.sprite.scripts.get(inp.block_id)
        if sub != null and sub.opcode in shadow_opcodes:
            var f = sub.fields.get(shadow_field)
            if f != null:
                return "\"%s\"" % esc(f.value)
    return ExpressionEmitter.emit(inp, ctx)

static func esc(s: String) -> String:
    return s.replace("\\", "\\\\").replace("\"", "\\\"")