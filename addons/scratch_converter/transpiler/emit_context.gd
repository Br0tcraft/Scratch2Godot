class_name EmitContext
extends RefCounted

var writer: CodeWriter
var sprite: ScratchSpriteModel
var project: ScratchProjectModel

var gd_global_var_names: Dictionary[String, String] = {}
var gd_global_list_names: Dictionary[String, String] = {}

var gd_local_var_names: Dictionary[String, String] = {}
var gd_local_list_names: Dictionary[String, String] = {}

var broadcast_names: Dictionary[String, String] = {}

var cloud_var_names: Dictionary[String, String] = {}

var proc_func_names: Dictionary[String, String] = {}

func gd_var_name(sb3_id: String) -> String:
    if gd_local_var_names.has(sb3_id):
        return gd_local_var_names[sb3_id]
    return gd_global_var_names.get(sb3_id, "_v_" + sb3_id)

func gd_list_name(sb3_id: String) -> String:
    if gd_local_list_names.has(sb3_id):
        return gd_local_list_names[sb3_id]
    return gd_global_list_names.get(sb3_id, "_l_" + sb3_id)

func is_broadcast_defined(name: String) -> bool:
    return broadcast_names.has(name)