class_name StatementEmitter
extends RefCounted

static func emit_chain(first_id: String, ctx: EmitContext) -> void:
	var current := first_id
	var guard := 0
	while current != "" and guard < 100000:
		var block: ScratchBlockModel = ctx.sprite.scripts.get(current)
		if block == null:
			ctx.writer.line("# dangling block ref: " + current)
			return
		emit(block, ctx)
		current = block.next
		guard += 1

static func emit(block: ScratchBlockModel, ctx: EmitContext) -> void:
	match block.blockType:
		ScratchBlockModel.BlockTypes.MOTION: MotionEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.CONTROL: ControlEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.LOOKS: LooksEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.EVENT: EventEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.SOUND: SoundEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.SENSING: SensingEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.DATA: DataEmitter.emit_statement(block, ctx)
		ScratchBlockModel.BlockTypes.PROCEDURES: ProceduresEmitter.emit_statement(block, ctx)
		_: ctx.writer.line("# TODO statement: " + block.opcode)