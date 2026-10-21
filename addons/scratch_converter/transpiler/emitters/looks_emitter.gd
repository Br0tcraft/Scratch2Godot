class_name LooksEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "looks_say":
            var m := ExpressionEmitter.emit(block.inputs.get("MESSAGE"), ctx)
            ctx.writer.line("looks.say(S.str(%s))" % m)
        "looks_sayforsecs":
            var m := ExpressionEmitter.emit(block.inputs.get("MESSAGE"), ctx)
            var s := ExpressionEmitter.emit(block.inputs.get("SECS"), ctx)
            ctx.writer.line("await looks.say_for(ctx, S.str(%s), S.num(%s))" % [m, s])
        "looks_think":
            var m := ExpressionEmitter.emit(block.inputs.get("MESSAGE"), ctx)
            ctx.writer.line("looks.think(S.str(%s))" % m)
        "looks_thinkforsecs":
            var m := ExpressionEmitter.emit(block.inputs.get("MESSAGE"), ctx)
            var s := ExpressionEmitter.emit(block.inputs.get("SECS"), ctx)
            ctx.writer.line("await looks.think_for(ctx, S.str(%s), S.num(%s))" % [m, s])
        "looks_show": ctx.writer.line("looks.show()")
        "looks_hide": ctx.writer.line("looks.hide()")
        "looks_hideallsprites":
            ctx.writer.line("pass  # legacy no-op")

        "looks_switchcostumeto":
            var c := EmitterHelpers.resolve_menu(
                block, "COSTUME", ["looks_costume"], "COSTUME", ctx)
            ctx.writer.line("looks.switch_costume(%s)" % c)
        "looks_nextcostume":
            ctx.writer.line("looks.next_costume()")
        "looks_switchbackdropto":
            var b := EmitterHelpers.resolve_menu(
                block, "BACKDROP", ["looks_backdrops"], "BACKDROP", ctx)
            ctx.writer.line("if stage: stage.looks.switch_costume(%s)" % b)
        "looks_switchbackdroptoandwait":
            var b := EmitterHelpers.resolve_menu(
                block, "BACKDROP", ["looks_backdrops"], "BACKDROP", ctx)
            ctx.writer.line("if stage: await stage.looks.switch_backdrop_and_wait(ctx, %s)" % b)
        "looks_nextbackdrop":
            ctx.writer.line("if stage: stage.looks.next_costume()")

        "looks_changesizeby":
            var d := ExpressionEmitter.emit(block.inputs.get("CHANGE"), ctx)
            ctx.writer.line("looks.change_size(S.num(%s))" % d)
        "looks_setsizeto":
            var d := ExpressionEmitter.emit(block.inputs.get("SIZE"), ctx)
            ctx.writer.line("looks.set_size(S.num(%s))" % d)

        "looks_changeeffectby":
            var en := _effect_name(block)
            var v := ExpressionEmitter.emit(block.inputs.get("CHANGE"), ctx)
            ctx.writer.line("looks.change_effect_%s(S.num(%s))" % [en, v])
        "looks_seteffectto":
            var en := _effect_name(block)
            var v := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("looks.set_effect_%s(S.num(%s))" % [en, v])
        "looks_cleargraphiceffects":
            ctx.writer.line("looks.clear_graphic_effects()")

        "looks_gotofrontback":
            var fb := _field(block, "FRONT_BACK", "front")
            if fb == "front":
                ctx.writer.line("looks.go_to_front()")
            else:
                ctx.writer.line("looks.go_to_back()")
        "looks_goforwardbackwardlayers":
            var dir := _field(block, "FORWARD_BACKWARD", "forward")
            var n := ExpressionEmitter.emit(block.inputs.get("NUM"), ctx)
            if dir == "forward":
                ctx.writer.line("looks.go_forward_layers(int(S.num(%s)))" % n)
            else:
                ctx.writer.line("looks.go_backward_layers(int(S.num(%s)))" % n)

        "looks_changestretchby": ctx.writer.line("pass")
        "looks_setstretchto": ctx.writer.line("pass")

        _:
            ctx.writer.line("# TODO looks: " + block.opcode)

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "looks_size": return "looks.get_size()"
        "looks_costumenumbername":
            var v := _field(block, "NUMBER_NAME", "number")
            return "looks.costume_number()" if v == "number" else "looks.costume_name()"
        "looks_backdropnumbername":
            var v := _field(block, "NUMBER_NAME", "number")
            return "stage.looks.costume_number()" if v == "number" else "stage.looks.costume_name()"
        "looks_costume":
            var f = block.fields.get("COSTUME")
            return "\"%s\"" % EmitterHelpers.esc(f.value if f else "")
        "looks_backdrops":
            var f = block.fields.get("BACKDROP")
            return "\"%s\"" % EmitterHelpers.esc(f.value if f else "")
    push_warning("LooksEmitter: unhandled expr " + block.opcode)
    return "0.0"


static func _effect_name(block: ScratchBlockModel) -> String:
    return _field(block, "EFFECT", "ghost").to_lower()

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val
