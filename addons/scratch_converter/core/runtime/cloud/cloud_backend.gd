class_name CloudBackend
extends Node

signal value_received(name: String, value: String)

func start() -> void: pass
func stop() -> void: pass
func send(_name: String, _value: String) -> void: pass