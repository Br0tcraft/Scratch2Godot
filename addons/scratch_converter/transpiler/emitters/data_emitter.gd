class_name DataEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "data_setvariableto":
            var f = block.fields.get("VARIABLE")
            var gd := _var_ref(f, ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("%s = %s" % [gd, v])
            _emit_cloud_sync(f, gd, ctx)
        "data_changevariableby":
            var f = block.fields.get("VARIABLE")
            var gd := _var_ref(f, ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("%s = S.num(%s) + S.num(%s)" % [gd, gd, v])
            _emit_cloud_sync(f, gd, ctx)
        "data_showvariable":
            ctx.writer.line("monitors.set_visibility(\"%s\", true)" % _id_of(block, "VARIABLE", ctx))
        "data_hidevariable":
            ctx.writer.line("monitors.set_visibility(\"%s\", false)" % _id_of(block, "VARIABLE", ctx))
        "data_addtolist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("ITEM"), ctx)
            ctx.writer.line("%s.append(%s)" % [gd, v])
        "data_deleteoflist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var i := ExpressionEmitter.emit(block.inputs.get("INDEX"), ctx)
            ctx.writer.line("S.list_delete(%s, %s)" % [gd, i])
        "data_deletealloflist":
            var f = block.fields.get("LIST")
            ctx.writer.line("%s.clear()" % _list_ref(f, ctx))
        "data_insertatlist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var i := ExpressionEmitter.emit(block.inputs.get("INDEX"), ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("ITEM"), ctx)
            ctx.writer.line("S.list_insert(%s, %s, %s)" % [gd, i, v])
        "data_replaceitemoflist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var i := ExpressionEmitter.emit(block.inputs.get("INDEX"), ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("ITEM"), ctx)
            ctx.writer.line("S.list_set(%s, %s, %s)" % [gd, i, v])
        "data_showlist":
            ctx.writer.line("monitors.set_visibility(\"%s\", true)" % _id_of(block, "LIST", ctx))
        "data_hidelist":
            ctx.writer.line("monitors.set_visibility(\"%s\", false)" % _id_of(block, "LIST", ctx))
        _:
            ctx.writer.line("# TODO data: " + block.opcode)

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "data_itemoflist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var i := ExpressionEmitter.emit(block.inputs.get("INDEX"), ctx)
            return "S.list_item(%s, %s)" % [gd, i]
        "data_itemnumoflist":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("ITEM"), ctx)
            return "S.list_index_of(%s, %s)" % [gd, v]
        "data_lengthoflist":
            var f = block.fields.get("LIST")
            return "%s.size()" % _list_ref(f, ctx)
        "data_listcontainsitem":
            var f = block.fields.get("LIST")
            var gd := _list_ref(f, ctx)
            var v := ExpressionEmitter.emit(block.inputs.get("ITEM"), ctx)
            return "(S.list_index_of(%s, %s) > 0)" % [gd, v]
        "data_variable":
            var f = block.fields.get("VARIABLE")
            return _var_ref(f, ctx)
        "data_listcontents":
            var f = block.fields.get("LIST")
            return "S.list_join(%s, \" \")" % _list_ref(f, ctx)
    return "0.0  # TODO data expr: " + block.opcode

static func _var_ref(field, ctx: EmitContext) -> String:
    if field == null: return "0.0  # missing var field"
    var id: String = field.id if "id" in field else ""
    if id.is_empty():
        id = _lookup_id_by_name(field.value, ctx)
    if not id.is_empty():
        if ctx.gd_local_var_names.has(id): return ctx.gd_local_var_names[id]
        if ctx.gd_global_var_names.has(id):
            if ctx.sprite == ctx.project.stage: return ctx.gd_global_var_names[id]
            return "stage." + ctx.gd_global_var_names[id]
    push_warning("Unresolved variable: " + str(field.value))
    return "0.0"

static func _list_ref(field, ctx: EmitContext) -> String:
    if field == null: return "[]"
    var id: String = field.id if "id" in field else ""
    if id.is_empty():
        id = _lookup_id_by_name(field.value, ctx)
    if not id.is_empty():
        if ctx.gd_local_list_names.has(id): return ctx.gd_local_list_names[id]
        if ctx.gd_global_list_names.has(id):
            if ctx.sprite == ctx.project.stage: return ctx.gd_global_list_names[id]
            return "stage." + ctx.gd_global_list_names[id]
    return "[]"

static func _lookup_id_by_name(name: String, ctx: EmitContext) -> String:
    for v in ctx.sprite.variables:
        if v.name == name: return v.id
    for l in ctx.sprite.lists:
        if l.name == name: return l.id
    for v in ctx.project.stage.variables:
        if v.name == name: return v.id
    for l in ctx.project.stage.lists:
        if l.name == name: return l.id
    return ""


static func _emit_cloud_sync(field, _gd_ref: String, ctx: EmitContext) -> void:
    if field == null: return
    var id: String = field.id if "id" in field else ""
    if id.is_empty():
        id = _lookup_id_by_name(field.value, ctx)
    if ctx.cloud_var_names.has(id):
        ctx.writer.line("_cloud_sync(\"%s\")" % EmitterHelpers.esc(ctx.cloud_var_names[id]))

static func _id_of(block, key: String, ctx: EmitContext) -> String:
    var f = block.fields.get(key)
    if f == null: return ""
    return f.id if f.id != "" else _lookup_id_by_name(f.value, ctx)