class_name ProceduresEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "procedures_call":
            var proccode: String = block.mutation.get("proccode", "")
            if proccode.is_empty():
                ctx.writer.line("# TODO procedures_call: missing proccode")
                return
            var func_name: String = ctx.proc_func_names.get(proccode, _proc_func_name(proccode))
            var arg_ids := _parse_arg_ids(block.mutation.get("argumentids", "[]"))
            var args: Array[String] = ["ctx"]
            for arg_id in arg_ids:
                args.append(ExpressionEmitter.emit(block.inputs.get(str(arg_id)), ctx))
            ctx.writer.line("await %s(%s)" % [func_name, ", ".join(args)])
        _:
            ctx.writer.line("# TODO procedures: " + block.opcode)

static func _parse_arg_ids(raw) -> Array:
    if raw is Array: return raw
    if raw is String:
        var p = JSON.parse_string(raw)
        if p is Array: return p
    return []

static func _sanitize_arg_name(raw: String) -> String:
    var out := ""
    for ch in raw:
        out += ch if (ch.is_valid_identifier() or ch == "_") else "_"
    if out.is_empty() or out[0].is_valid_int():
        out = "_" + out
    return "_arg_" + out.to_lower()

static func _proc_func_name(proccode: String) -> String:
    var out := "proc_"
    for ch in proccode:
        if ch.is_valid_identifier() or ch == "_" or ch == " " or ch == "%":
            out += "_" if (ch == " " or ch == "%") else ch
    return out.to_lower().strip_edges()