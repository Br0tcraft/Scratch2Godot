class_name OperatorEmitter
extends RefCounted

static func emit_expression(block: ScratchBlockModel, ctx: EmitContext) -> String:
    match block.opcode:
        "operator_add":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("NUM2"), ctx)
            return "(S.num(%s) + S.num(%s))" % [a, b]
        "operator_subtract":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("NUM2"), ctx)
            return "(S.num(%s) - S.num(%s))" % [a, b]
        "operator_multiply":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("NUM2"), ctx)
            return "(S.num(%s) * S.num(%s))" % [a, b]
        "operator_divide":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("NUM2"), ctx)
            return "(S.num(%s) / S.num(%s))" % [a, b]
        "operator_mod":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("NUM2"), ctx)
            return "fmod(S.num(%s), S.num(%s))" % [a, b]
        "operator_round":
            var a := ExpressionEmitter.emit(block.inputs.get("NUM"), ctx)
            return "round(S.num(%s))" % a
        "operator_random":
            var lo := ExpressionEmitter.emit(block.inputs.get("FROM"), ctx)
            var hi := ExpressionEmitter.emit(block.inputs.get("TO"), ctx)
            return "_scratch_random(%s, %s)" % [lo, hi]
        "operator_mathop":
            var op: String = _field(block, "OPERATOR", "abs")
            var x := ExpressionEmitter.emit(block.inputs.get("NUM"), ctx)
            return "ScratchOperators.mathop(\"%s\", S.num(%s))" % [op, x]
        "operator_lt":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("OPERAND2"), ctx)
            return "(S.compare(%s, %s) < 0)" % [a, b]
        "operator_gt":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("OPERAND2"), ctx)
            return "(S.compare(%s, %s) > 0)" % [a, b]
        "operator_equals":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("OPERAND2"), ctx)
            return "S.equals(%s, %s)" % [a, b]
        "operator_and":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("OPERAND2"), ctx)
            return "(S.boolean(%s) and S.boolean(%s))" % [a, b]
        "operator_or":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("OPERAND2"), ctx)
            return "(S.boolean(%s) or S.boolean(%s))" % [a, b]
        "operator_not":
            var a := ExpressionEmitter.emit(block.inputs.get("OPERAND"), ctx)
            return "(not S.boolean(%s))" % a
        "operator_join":
            var a := ExpressionEmitter.emit(block.inputs.get("STRING1"), ctx)
            var b := ExpressionEmitter.emit(block.inputs.get("STRING2"), ctx)
            return "(S.str(%s) + S.str(%s))" % [a, b]
        "operator_letter_of":
            var i := ExpressionEmitter.emit(block.inputs.get("LETTER"), ctx)
            var s := ExpressionEmitter.emit(block.inputs.get("STRING"), ctx)
            return "ScratchOperators.letter_of(%s, %s)" % [i, s]
        "operator_length":
            var s := ExpressionEmitter.emit(block.inputs.get("STRING"), ctx)
            return "S.str(%s).length()" % s
        "operator_contains":
            var s := ExpressionEmitter.emit(block.inputs.get("STRING1"), ctx)
            var t := ExpressionEmitter.emit(block.inputs.get("STRING2"), ctx)
            return "S.str(%s).to_lower().contains(S.str(%s).to_lower())" % [s, t]
    push_warning("Unresolved operator expression: " + block.opcode)
    return "0.0"

static func _scratch_random(lo, hi) -> Variant:
    var a := S.num(lo)
    var b := S.num(hi)
    if a == floor(a) and b == floor(b):
        var lo_i := int(a); var hi_i := int(b)
        if lo_i > hi_i: var t := lo_i; lo_i = hi_i; hi_i = t
        return randi_range(lo_i, hi_i)
    return randf_range(min(a, b), max(a, b))

static func _field(block: ScratchBlockModel, key: String, default_val: String) -> String:
    var f = block.fields.get(key)
    return f.value if f else default_val