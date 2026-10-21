class_name SoundEmitter
extends RefCounted

static func emit_statement(block: ScratchBlockModel, ctx: EmitContext) -> void:
    match block.opcode:
        "sound_play":
            var snd := _resolve_sound_menu(block, "SOUND_MENU", ctx)
            ctx.writer.line("sound.play(%s)" % snd)
        "sound_playuntildone":
            var snd := _resolve_sound_menu(block, "SOUND_MENU", ctx)
            ctx.writer.line("await sound.play_until_done(ctx, %s)" % snd)
        "sound_stopallsounds":
            ctx.writer.line("sound.stop_all()")
        "sound_seteffectto":
            var en := _field(block, "EFFECT", "pitch")
            var v := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("sound.set_effect_%s(S.num(%s))" % [en, v])
        "sound_changeeffectby":
            var en := _field(block, "EFFECT", "pitch")
            var v := ExpressionEmitter.emit(block.inputs.get("VALUE"), ctx)
            ctx.writer.line("sound.change_effect_%s(S.num(%s))" % [en, v])
        "sound_cleareffects":
            ctx.writer.line("sound.clear_effects()")
        "sound_setvolumeto":
            var v := ExpressionEmitter.emit(block.inputs.get("VOLUME"), ctx)
            ctx.writer.line("sound.set_volume(S.num(%s))" % v)
        "sound_changevolumeby":
            var v := ExpressionEmitter.emit(block.inputs.get("VOLUME"), ctx)
            ctx.writer.line("sound.change_volume(S.num(%s))" % v)
        _:
            ctx.writer.line("# TODO sound: " + block.opcode)

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "sound_volume": return "sound.get_volume()"
    return "0.0"

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val

static func _resolve_sound_menu(block: ScratchBlockModel, input_key: String, ctx: EmitContext) -> String:
    var inp = block.inputs.get(input_key)
    if inp == null:
        return "\"\""
    if inp.type == ScratchInputModel.InputType.VALUE:
        return "\"%s\"" % EmitterHelpers.esc(str(inp.value))
    var sub: ScratchBlockModel = ctx.sprite.scripts.get(inp.block_id)
    if sub != null and sub.opcode == "sound_sounds_menu":
        var f = sub.fields.get("SOUND_MENU")
        if f != null:
            return "\"%s\"" % EmitterHelpers.esc(f.value)
    return ExpressionEmitter.emit(inp, ctx)
