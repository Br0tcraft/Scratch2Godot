class_name ScriptBuilder
extends RefCounted

const HEADER := "extends ScratchSprite\n"

var ctx: EmitContext
var _hats: Array = [] # [{trigger:String, extra:Variant, func_name:String}]
var _hat_counts: Dictionary = {}

func build(sprite: ScratchSpriteModel, project: ScratchProjectModel) -> String:
    _hats.clear()
    _hat_counts.clear()
    ctx = EmitContext.new()
    ctx.writer = CodeWriter.new()
    ctx.sprite = sprite
    ctx.project = project

    if sprite == project.stage:
        _collect_global_var_names(sprite.variables, sprite.lists)
    else:
        _collect_local_var_names(sprite.variables, sprite.lists)
        _collect_global_var_names(project.stage.variables, project.stage.lists)
    _collect_broadcasts(sprite)

    _collect_cloud_vars()

    _collect_proc_func_names(sprite)

    for hat_block in _find_top_level_hats(sprite):
        if hat_block.opcode == "procedures_definition":
            _emit_procedure_definition(hat_block)
        else:
            _emit_hat_function(hat_block)

    var out := HEADER
    out += _emit_var_declarations()
    out += _emit_var_accessors()
    out += _emit_register_monitors()
    out += _emit_hat_registration()
    out += ctx.writer.get_text()
    return out

func _collect_local_var_names(vars: Array[ScratchVariableModel], lists: Array[ScratchListModel]) -> void:
    for v in vars:
        if not ctx.gd_local_var_names.has(v.id):
            ctx.gd_local_var_names[v.id] = _sanitize("_v_" + v.name)
    for l in lists:
        if not ctx.gd_local_list_names.has(l.id):
            ctx.gd_local_list_names[l.id] = _sanitize("_l_" + l.name)

func _collect_global_var_names(vars: Array[ScratchVariableModel], lists: Array[ScratchListModel]) -> void:
    for v in vars:
        if not ctx.gd_global_var_names.has(v.id):
            ctx.gd_global_var_names[v.id] = _sanitize("_v_" + v.name)
    for l in lists:
        if not ctx.gd_global_list_names.has(l.id):
            ctx.gd_global_list_names[l.id] = _sanitize("_l_" + l.name)

func _collect_broadcasts(sprite: ScratchSpriteModel) -> void:
    for b in sprite.broadcasts:
        ctx.broadcast_names[b.name] = _sanitize("bc_" + b.name)

func _sanitize(raw: String) -> String:
    var out := ""
    for ch in raw:
        out += ch if (ch.is_valid_identifier() or ch == "_") else "_"
    if out.is_empty() or out[0].is_valid_int():
        out = "_" + out
    return out.to_lower()

func _collect_cloud_vars() -> void:
    for v in ctx.project.stage.variables:
        if v.type == ScratchVariableModel.VariableTypes.CLOUD or v.type == ScratchVariableModel.VariableTypes.STORAGE:
            ctx.cloud_var_names[v.id] = v.name

func _emit_cloud_var_map() -> String:
    if not _is_stage():
        return ""
    var entries: Array[String] = []
    for v in ctx.sprite.variables:
        if v.type == ScratchVariableModel.VariableTypes.CLOUD or v.type == ScratchVariableModel.VariableTypes.STORAGE:
            var gd_name = ctx.gd_global_var_names.get(v.id, ctx.gd_local_var_names.get(v.id, ""))
            if not gd_name.is_empty():
                entries.append("\t\t\"%s\": \"%s\"," % [EmitterHelpers.esc(v.name), gd_name])
    if entries.is_empty():
        return ""
    var out := "\tcloud_var_map = {\n"
    out += "\n".join(entries) + "\n"
    out += "\t}\n"
    return out

func _find_top_level_hats(sprite: ScratchSpriteModel) -> Array:
    var result: Array = []
    for block in sprite.scripts.values():
        if block.parent != "":
            continue
        if _is_hat_opcode(block.opcode):
            result.append(block)
    return result

func _is_hat_opcode(op: String) -> bool:
    return op in [
        "event_whenflagclicked",
        "event_whenbroadcastreceived",
        "event_whenkeypressed",
        "event_whenthisspriteclicked",
        "event_whenstageclicked",
        "event_whentouchingobject",
        "event_whenbackdropswitchesto",
        "event_whengreaterthan",
        "control_start_as_clone",
        "procedures_definition",
    ] or op.begins_with("event_when")


func _emit_hat_function(hat_block: ScratchBlockModel) -> void:
    var func_name := _hat_func_name(hat_block)
    _hats.append({
        "trigger": _hat_trigger(hat_block),
        "extra": _hat_extra(hat_block),
        "func_name": func_name,
    })

    ctx.writer.line()
    ctx.writer.line("func %s(ctx: ScriptContext) -> void:" % func_name)
    ctx.writer.indent()
    if hat_block.next.is_empty():
        ctx.writer.line("pass")
    else:
        StatementEmitter.emit_chain(hat_block.next, ctx)
    ctx.writer.line("return")
    ctx.writer.dedent()

func _hat_func_name(hat: ScratchBlockModel) -> String:
    var base := hat.opcode.replace("event_", "").replace("control_", "").replace("_", "")
    if base.is_empty():
        base = "event"
    var count: int = _hat_counts.get(base, 0) + 1
    _hat_counts[base] = count
    if count == 1:
        return "hat_%s" % base
    return "hat_%s_%d" % [base, count]

func _hat_trigger(hat: ScratchBlockModel) -> String:
    match hat.opcode:
        "event_whenflagclicked": return "GREEN_FLAG"
        "event_whenbroadcastreceived": return "BROADCAST"
        "event_whenkeypressed": return "KEY_PRESSED"
        "event_whenthisspriteclicked": return "CLICKED"
        "event_whenstageclicked": return "CLICKED"
        "event_whentouchingobject": return "TOUCHING"
        "event_whenbackdropswitchesto": return "BACKDROP_SWITCH"
        "event_whengreaterthan": return "GREATER_THAN"
        "control_start_as_clone": return "CLONE_START"
    return "UNKNOWN"

func _hat_extra(hat: ScratchBlockModel) -> Variant:
    match hat.opcode:
        "event_whenbroadcastreceived":
            var f = hat.fields.get("BROADCAST_OPTION")
            return f.value if f else ""
        "event_whenkeypressed":
            var f = hat.fields.get("KEY_OPTION")
            var raw_key: String = f.value if f else ""
            return raw_key
        "event_whenbackdropswitchesto":
            var f = hat.fields.get("BACKDROP")
            return f.value if f else ""
        "event_whengreaterthan":
            var f = hat.fields.get("WHENGREATERTHANMENU")
            var v = hat.inputs.get("WHENGREATERTHANINPUT")
            return {
                "menu": f.value if f else "",
                "value": ExpressionEmitter.emit(v, ctx) if v else 0.0,
            }
    return null

func _emit_var_declarations() -> String:
    var decl_vars := ctx.gd_global_var_names if _is_stage() else ctx.gd_local_var_names
    var decl_lists := ctx.gd_global_list_names if _is_stage() else ctx.gd_local_list_names
    if decl_vars.is_empty() and decl_lists.is_empty():
        return ""
    var out := ""
    for id in decl_vars:
        out += "var %s: Variant = 0.0\n" % decl_vars[id]
    for id in decl_lists:
        out += "var %s: Array = []\n" % decl_lists[id]
    return out

func _is_stage() -> bool:
    return ctx.sprite == ctx.project.stage

func _emit_var_accessors() -> String:
    var names := ctx.gd_global_var_names if _is_stage() else ctx.gd_local_var_names
    var out := "\n\nfunc _scratch_get_var(id: String) -> Variant:\n"
    if names.is_empty():
        out += "\treturn 0.0\n"
    else:
        out += "\tmatch id:\n"
        for id in names:
            out += "\t\t\"%s\": return %s\n" % [id, names[id]]
        out += "\treturn 0.0\n"

    out += "\n\nfunc _scratch_set_var(id: String, val: Variant) -> void:\n"
    if names.is_empty():
        out += "\treturn\n"
    else:
        out += "\tmatch id:\n"
        for id in names:
            out += "\t\t\"%s\": %s = val\n" % [id, names[id]]
        out += "\treturn\n"
    return out

func _emit_hat_registration() -> String:
    var out := "\n\nfunc _register_hats() -> void:\n"
    out += _emit_cloud_var_map()
    if _hats.is_empty():
        if out.ends_with(":\n"):
            out += "\tpass\n"
        return out
    for h in _hats:
        if h.extra == null:
            out += "\tregister_hat(Trigger.%s, %s)\n" % [h.trigger, h.func_name]
        else:
            out += "\tregister_hat(Trigger.%s, %s, \"%s\")\n" % [h.trigger, h.func_name, str(h.extra).replace("\"", "\\\"")]
    out += _emit_copy_locals()
    return out

func _emit_copy_locals() -> String:
    if _is_stage() or (ctx.gd_local_var_names.is_empty() and ctx.gd_local_list_names.is_empty()):
        return ""
    var out := "\n\nfunc _copy_locals_from(src: ScratchSprite) -> void:\n\tvar o = src\n"
    for id in ctx.gd_local_var_names:
        out += "\t%s = o.%s\n" % [ctx.gd_local_var_names[id], ctx.gd_local_var_names[id]]
    for id in ctx.gd_local_list_names:
        out += "\t%s = o.%s.duplicate(true)\n" % [ctx.gd_local_list_names[id], ctx.gd_local_list_names[id]]
    return out

func _emit_register_monitors() -> String:
    var owner_vars := ctx.gd_global_var_names if _is_stage() else ctx.gd_local_var_names
    var owner_lists := ctx.gd_global_list_names if _is_stage() else ctx.gd_local_list_names
    var out := "\n\nfunc _register_monitors() -> void:\n"
    if owner_vars.is_empty() and owner_lists.is_empty():
        return out + "\tpass\n"
    for v in ctx.sprite.variables:
        if owner_vars.has(v.id):
            out += _monitor_line("add_variable", v.id, owner_vars[v.id], v.name)
    for l in ctx.sprite.lists:
        if owner_lists.has(l.id):
            out += _monitor_line("add_list", l.id, owner_lists[l.id], l.name)
    return out

func _monitor_line(fn: String, id: String, gd: String, label: String) -> String:
    var m := ctx.project.find_monitor(id)
    var prefix := "" if _is_stage() else ctx.sprite.sprite_name + ": "
    var cfg := {"x": 5, "y": 5, "mode": "normal", "visible": false, "min": 0.0, "max": 100.0, "discrete": true}
    if m != null:
        cfg = {"x": m._x, "y": m._y, "mode": ["normal", "large", "slider", "list"][m._mode],
            "visible": m.visible, "min": m.slider_min, "max": m.slider_max, "discrete": m.is_discrete}
    return "\tmonitors.%s(self, \"%s\", \"%s\", \"%s\", %s)\n" % [
        fn, EmitterHelpers.esc(id), gd, EmitterHelpers.esc(prefix + label), var_to_str(cfg).replace("\n", " ")]

func _collect_proc_func_names(sprite: ScratchSpriteModel) -> void:
    var used: Dictionary = {}
    for block in sprite.scripts.values():
        if block.opcode != "procedures_definition" or block.parent != "":
            continue
        var pc := _get_proc_proccode(block)
        if pc.is_empty() or ctx.proc_func_names.has(pc):
            continue
        var base := ProceduresEmitter._proc_func_name(pc)
        var name := base
        var counter := 1
        while used.has(name):
            counter += 1
            name = "%s_%d" % [base, counter]
        used[name] = true
        ctx.proc_func_names[pc] = name

func _get_proc_proccode(block: ScratchBlockModel) -> String:
    var pin := block.inputs.get("custom_block")
    if pin == null: return ""
    var proto = ctx.sprite.scripts.get(pin.block_id)
    if proto == null: return ""
    return proto.mutation.get("proccode", "")

func _get_proc_arg_names(block: ScratchBlockModel) -> Array:
    var pin := block.inputs.get("custom_block")
    if pin == null: return []
    var proto = ctx.sprite.scripts.get(pin.block_id)
    if proto == null: return []
    var raw = proto.mutation.get("argumentnames", "[]")
    if raw is Array: return raw
    if raw is String:
        var p = JSON.parse_string(raw)
        if p is Array: return p
    return []

func _emit_procedure_definition(block: ScratchBlockModel) -> void:
    var pc := _get_proc_proccode(block)
    if pc.is_empty():
        ctx.writer.line()
        ctx.writer.line("# TODO procedure definition: missing proccode")
        return
    var args := _get_proc_arg_names(block)
    var fname := ctx.proc_func_names.get(pc, ProceduresEmitter._proc_func_name(pc))
    var params := "ctx: ScriptContext"
    for a in args:
        params += ", %s: Variant" % ProceduresEmitter._sanitize_arg_name(str(a))
    ctx.writer.line()
    ctx.writer.line("func %s(%s) -> void:" % [fname, params])
    ctx.writer.indent()
    if block.next.is_empty():
        ctx.writer.line("pass")
    else:
        StatementEmitter.emit_chain(block.next, ctx)
    ctx.writer.line("return")
    ctx.writer.dedent()