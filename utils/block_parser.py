from utils.helpers import get_loop_varname, convert_key
def convert_blocks(blocks: dict, block: dict, code: str, name: str, spaces: int):
    var = {}
    def convert_block(blocks: dict, block: dict, space: int, code: str, name: str):
        spaces = "\t" * space
        print(block)
        while "opcode" in block and "next" in block:
            print("opcode:" + str(block["opcode"]))
            try:
                match block["opcode"]:
                    #motion-blocks
                    case "motion_movesteps":
                        var["steps"] = 0
                        code += "\n" + spaces + 'steps = correctur.ms(' + str(repeat_content(blocks, block, "STEPS")) + f', "float", "res://scripts/{name}.gd", "move steps (!)")\n'
                        code += spaces + "object.position += Vector2(cos(deg_to_rad(object.direction - 90)), sin(deg_to_rad(object.direction - 90))) * steps\n"
                    case "motion_moveupdownsteps":
                        var["rotate"] = 0
                        var["steps"] = 0
                        code += "\n" + spaces + 'steps = correctur.ms(' + str(repeat_content(blocks, block, "STEPS")) + f', "float", "res://scripts/{name}.gd", "move [up/down] (!) steps")\n'
                        if block["fields"]["DIRECTION"] == "up":
                            code += spaces + "object.position -= Vector2(cos(deg_to_rad(object.direction)), sin(deg_to_rad(object.direction))) * steps\n"
                        else:
                            code += spaces + "object.position += Vector2(cos(deg_to_rad(object.direction)), sin(deg_to_rad(object.direction))) * steps\n"

                    case "motion_turnright":
                        var["spin"] = 0
                        code += "\n" + spaces + 'spin = correctur.ms(' + str(repeat_content(blocks, block, "DEGREES")) + f', "float", "res://scripts/{name}.gd", "turn right (!)")\n'
                        code += spaces + 'object.direction += spin\n'
                        code += spaces + "object.direction = op.rotate(object.direction)\n"
                        code += spaces + 'if object.rotation_type == "all around":\n'
                        code += spaces + "\tanimation.rotation = deg_to_rad(object.direction - 90)\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                        code += spaces + "else:\n"
                        code += spaces + "\tanimation.rotation = 0\n"
                    case "motion_turnleft":
                        var["spin"] = 0
                        code += "\n" + spaces + 'spin = correctur.ms(' + str(repeat_content(blocks, block, "DEGREES")) + f', "float", "res://scripts/{name}.gd", "turn left (!)")\n'
                        code += spaces + 'object.direction -= spin\n'
                        code += spaces + "object.direction = op.rotate(object.direction)\n"
                        code += spaces + 'if object.rotation_type == "all around":\n'
                        code += spaces + "\tanimation.rotation = deg_to_rad(object.direction - 90)\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                        code += spaces + "else:\n"
                        code += spaces + "\tanimation.rotation = 0\n"
                    case "motion_gotoxy":
                        var["Xnew"] = 0
                        var["Ynew"] = 0
                        code += "\n" + spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "go to x:(!) y:()")\n'
                        code += spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "go to x:() y:(!)")\n'
                        code += spaces + "object.position = Vector2(Xnew, Ynew * -1.0)\n"
                    case "motion_goto":
                        var["goTo"] = "null"
                        var["target_node"] = "null"
                        code += "\n" + spaces + "goTo = " + str(repeat_content(blocks, block, "TO")) + "\n"
                        code += spaces + f'if str(goTo) == "_mouse_":\n'
                        code += spaces + f"\tobject.position = get_global_mouse_position()\n"
                        code += spaces + f'elif str(goTo) == "_random_":\n'
                        code += spaces + f'\tobject.position = Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2))\n'
                        code += spaces + "else:\n"
                        code += spaces + '\ttarget_node = main.get_node_or_null(str(goTo))\n'
                        code += spaces + '\tif target_node and target_node is Node2D:\n'
                        code += spaces + '\t\tobject.position = target_node.position\n'
                        code += spaces + '\telse:\n'
                        code += spaces + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "go to ()", str(goTo))\n'
                    case "motion_glideto":
                        var["secs"] = 0
                        var["goTo"] = "null"
                        var["tweenPos"] = "null"
                        var["target_node"] = "null"
                        code += "\n" + spaces + "secs = correctur.ms(" + str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "glide (!) secs to ()")\n'
                        code += spaces + "goTo = " + str(repeat_content(blocks, block, "TO")) + "\n"
                        code += spaces + f'tweenPos = object.create_tween()\n'
                        code += spaces + f'if str(goTo) == "_mouse_":\n'
                        code += spaces + f'\ttweenPos.tween_property(object, "position", get_global_mouse_position(), secs)\n'
                        code += spaces + f'elif str(goTo) == "_random_":\n'
                        code += spaces + f'\ttweenPos.tween_property(object, "position", Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2)), secs)\n'
                        code += spaces + "else:\n"
                        code += spaces + '\ttarget_node = get_node_or_null("/root/Main/" + str(goTo))\n'
                        code += spaces + '\tif target_node and target_node is Node2D:\n'
                        code += spaces + '\t\ttweenPos.tween_property(object, "position", target_node.position, secs)\n'
                        code += spaces + '\telse:\n'
                        code += spaces + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "glide () secs to (!)", str(goTo))\n'
                        code += spaces + 'await tweenPos.finished\n'
                    case "motion_glidesecstoxy":
                        var["secs"] = 0
                        var["Xnew"] = 0
                        var["Ynew"] = 0
                        var["tweenPos"] = "null"
                        code += "\n" + spaces + "secs = correctur.ms(" + str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "glide (!) secs to x:() y:()")\n'
                        code += spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "glide () secs to x:(!) y:()")\n'
                        code += spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "glide () secs to x:() y:(!)")\n'
                        code += spaces + "tweenPos = object.create_tween()\n"
                        code += spaces + 'tweenPos.tween_property(object, "position", Vector2(Xnew, Ynew * -1.0), secs)\n'
                        code += spaces + 'await tweenPos.finished\n'
                    case "motion_pointtowards":
                        var["lookat"] = '""'
                        code += "\n" + spaces + "lookat = " + str(repeat_content(blocks, block, "TOWARDS")) + "\n"
                        code += spaces + f'if str(lookat) == "_mouse_":\n'
                        code += spaces + f"\tanimation.look_at(get_global_mouse_position())\n"
                        code += spaces + '\tobject.direction  = rad_to_deg(animation.rotation) + 90\n'
                        code += spaces + "else:\n"
                        code += spaces + '\tlookat = main.get_node_or_null(str(lookat))\n'
                        code += spaces + '\tif lookat and lookat is Node2D:\n'
                        code += spaces + '\t\tanimation.look_at(lookat.position)\n'
                        code += spaces + '\t\tobject.direction = op.rotate(rad_to_deg(animation.rotation) + 90)\n'
                        code += spaces + '\telse:\n'
                        code += spaces + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "point towards (!)", str(lookat))\n'
                        code += spaces + '''if object.rotation_type == "don't rotate":\n'''
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                    case "motion_pointindirection":
                        var["rotate"] = 0
                        code += "\n" + spaces + "object.direction = correctur.ms(" + str(repeat_content(blocks, block, "DIRECTION")) + f', "float", "res://scripts/{name}.gd", "point in direction (!)")\n'
                        code += spaces + 'if object.rotation_type == "all around":\n'
                        code += spaces + "\tanimation.rotation = deg_to_rad(object.direction - 90)\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                        code += spaces + "else:\n"
                        code += spaces + "\tanimation.rotation = 0\n"
                    case "motion_pointtowardsxy":
                        var["Xnew"] = 0
                        var["Ynew"] = 0
                        code += "\n" + spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "point towards x:(!) y:()")\n'
                        code += spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "point towards x:() y:(!)")\n'
                        code += spaces + "animation.look_at(Vector2(Xnew, Ynew * -1.0))\n"
                        code += spaces + 'object.direction = rad_to_deg(animation.rotation) + 90\n'
                        code += spaces + '''if object.rotation_type == "don't rotate":\n'''
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                        code += spaces + "else:\n"
                        code += spaces + "\tanimation.rotation = 0\n"
                    case "motion_turnaround":
                        code += "\n" + spaces + 'animation.rotation += PI\n'
                    case "motion_changexby":
                        var["Xnew"] = 0
                        code += "\n" + spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "DX")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
                        code += spaces + "object.position.x += Xnew\n"
                    case "motion_changeyby":
                        var["Ynew"] = 0
                        code += "\n" + spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "DY")) + f', "float", "res://scripts/{name}.gd", "change y by (!)")\n'
                        code += spaces + "object.position.y -= Ynew\n"
                    case "motion_changebyxy":
                        var["Ynew"] = 0
                        var["Xnew"] = 0
                        code += "\n" + spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "DY")) + f', "float", "res://scripts/{name}.gd", "change by x:() y: (!)")\n'
                        code += spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "DX")) + f', "float", "res://scripts/{name}.gd", "change by x:(!) y:()")\n'
                        code += spaces + "object.position.x += Xnew\n"
                        code += spaces + "object.position.y -= Ynew\n"
                    case "motion_setx":
                        var["Xnew"] = 0
                        code += "\n" + spaces + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
                        code += spaces + "object.position.y = Xnew\n"
                    case "motion_sety":
                        var["Ynew"] = 0
                        code += "\n" + spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
                        code += spaces + "object.position.y = Ynew * -1.0\n"
                    case "motion_sety":
                        var["Ynew"] = 0
                        code += "\n" + spaces + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
                        code += spaces + "object.position.y = Ynew * -1.0\n"
                    case "motion_setrotationstyle":
                        code += "\n" + spaces + 'object.rotation_type = '+ str(repeat_content(blocks, block, "STYLE")) + '\n'
                        code += spaces + 'if object.rotation_type == "all around":\n'
                        code += spaces + "\tanimation.rotation = deg_to_rad(object.direction - 90)\n"
                        code += spaces + 'elif object.rotation_type == "left-right":\n'
                        code += spaces + "\tanimation.rotation = 0\n"
                        code += spaces + "\tif object.direction > 0:\n"
                        code += spaces + "\t\tanimation.scale.x = object.stretch.x / 100\n"
                        code += spaces + "\telse:\n"
                        code += spaces + "\t\tanimation.scale.x = -1 * object.stretch.x / 100\n"
                        code += spaces + "else:\n"
                        code += spaces + "\tanimation.rotation = 0\n"
                    case "motion_ifonedgebounce":
                        var["size"] = 'Vector2(0 ,0)'
                        var["cameraPos"] = 'Vector2(0 ,0)'
                        code += "\n" + spaces + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * animation.scale / 2\n'
                        code += spaces + 'cameraPos = $"../../../../Camera2D".global_position\n'
                        code += spaces + 'if object.position.x - size.x < cameraPos.x - get_viewport().size.x / 2 or object.position.x + size.x > cameraPos.x + get_viewport().size.x / 2 or object.position.y - size.y < cameraPos.y - get_viewport().size.y / 2 or object.position.y + size.y > cameraPos.y + get_viewport().size.y / 2:\n'
                        code += spaces + '\tobject.direction = op.rotate(object.direction + 90)\n'
                    case "motion_ifonspritebounce":
                        var["sprite"] = '""'
                        var["size"] = 'Vector2(0 ,0)'
                        var["size2"] = 'Vector2(0 ,0)'
                        code += "\n" + spaces + 'sprite = correctur.ms("' + str(repeat_content(blocks, block, "SPRITE")) + f'", "string", "res://scripts/{name}.gd", "if touching (!) bounce")\n'
                        code += spaces + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * animation.scale / 2\n'
                        code += spaces + 'if sprite == "_mouse_":\n'
                        code += spaces + '\tif get_global_mouse_position().x > object.position.x - size.x and get_global_mouse_position().x < object.position.x + size.x and get_global_mouse_position().y > object.position.y - size.y and get_global_mouse_position().y < object.position.y + size.y:\n'
                        code += spaces + '\t\tif "mouse" in object.last_touch and object.last_touch["mouse"] == "false":\n'
                        code += spaces + '\t\t\tobject.direction = op.rotate(object.direction + 180)\n'
                        code += spaces + '\t\tlast_touch["mouse] = "true"\n'
                        code += spaces + '\telse:\n'
                        code += spaces + '\t\tlast_touch["mouse"] = "false"\n'
                        code += spaces + 'elif sprite == "_random_":\n'
                        code += spaces + f'''\tprint("WARNING: In script 'res://scripts/{name}.gd', the converted block 'if touching () bounce' received an invalid value ('_random_')")\n'''
                        code += spaces + f'''\tprint("   This can happen because this block and the “point towards()” block use the same menu")\n'''
                        code += spaces + f'''\tprint( → to avoid errors, the block did nothing")\n'''
                        code += spaces + f'''\tcorrectur.help()\n'''
                        code += spaces + f'elif get_node_or_null(str(sprite)):\n'
                        code += spaces + f'\tsprite = main.get_node(str(sprite))\n'
                        code += spaces + f'\tsize = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * animation.scale / 2\n'
                        code += spaces + f'\tsize2 = sprite.get_node("Sprite").sprite_frames.get_frame_texture(sprite.get_node("Sprite").animation, 0).get_size() * sprite.scale / 2\n'
                        code += spaces + f'\tif abs(object.position.x - sprite.position.x) < size.x + size2.x and abs(object.position.y - sprite.position.y) < size.y + size2.y:\n'
                        code += spaces + f'\t\tobject.direction = op.rotate(object.direction + 90)\n'
                    case "motion_move_sprite_to_scene_side":
                        var["cameraPos"] = 'Vector2(0 ,0)'
                        var["size"] = 'Vector2(0 ,0)'
                        try:
                            alignment = block["fields"]["ALIGNMENT"][0]
                            code += "\n" + spaces + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * animation.scale / 2\n'
                            code += spaces + 'cameraPos = $"../../../../Camera2D".global_position\n'
                            match alignment:
                                case "top-left":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                                case "top-right":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                                case "bottom-left":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                                case "bottom-right":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                                case "top":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                                case "bottom":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                                case "left":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
                                case "right":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
                                case "middle":
                                    code += spaces + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
                        except:
                            code += "\n" + spaces + '''print(Soemthing was wrong with the scratch-file. The Block 'move to stage [!]' has a not valid value)\n'''
                            code += spaces + '''correctur.help()\n'''

                    # look_blocks
                    case "looks_sayforsecs":
                        var["message"] = '""'
                        var["secs"] = 0
                        code += "\n" + spaces + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "say (!) for () seconds")\n'
                        code += spaces + 'secs = correctur.ms('+ str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "say () for (!) seconds")\n'
                        code += spaces + f'$"../../../bubble".write(message, secs)\n'
                        code += spaces + f'await get_tree().create_timer(secs).timeout\n'
                    case "looks_say":
                        var["message"] = '""'
                        var["secs"] = 0
                        code += "\n" + spaces + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "say (!)")\n'
                        code += spaces + f'$"../../../bubble".write(message, INF)\n'
                    case "looks_thinkforsecs":
                        var["message"] = '""'
                        var["secs"] = 0
                        code += "\n" + spaces + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "think (!) for () seconds")\n'
                        code += spaces + 'secs = correctur.ms('+ str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "think () for (!) seconds")\n'
                        code += spaces + f'$"../../../bubble".write(message, secs, false)\n'
                        code += spaces + f'await get_tree().create_timer(secs).timeout\n'
                    case "looks_think":
                        var["message"] = '""'
                        var["secs"] = 0
                        code += "\n" + spaces + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "think (!)")\n'
                        code += spaces + f'$"../../../bubble".write(message, INF, false)\n'
                    case "looks_show":
                        code += "\n" + spaces + 'object.show()\n'
                    case "looks_hide":
                        code += "\n" + spaces + 'object.hide()\n'
                    case "looks_switchcostumeto":
                        var["costume"] = '""'
                        code += "\n" + spaces + 'costume = correctur.ms('+ str(repeat_content(blocks, block, "COSTUME")) + f', "string", "res://scripts/{name}.gd", "switch costume to (!)")\n'
                        code += spaces + f'$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = true\n'
                        code += spaces + f'if str(costume).is_valid_int():\n'
                        code += spaces + f'\tanimation.play(animation.sprite_frames.get_animation_names()[int(costume) % animation.sprite_frames.get_animation_names().size()])\n'
                        code += spaces + f'elif costume in animation.sprite_frames.get_animation_names():\n'
                        code += spaces + f'\tanimation.play(str(costume))\n'
                        code += spaces + f'$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = false\n'
                    case "looks_nextcostume":
                        code += "\n" + spaces + f'$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = true\n'
                        code += spaces + f'animation.play(animation.sprite_frames.get_animation_names()[((animation.sprite_frames.get_animation_names().find(animation.animation) + 1) % animation.sprite_frames.get_animation_names().size())])\n'
                        code += spaces + f'$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = false\n'
                    case "looks_switchbackdropto":
                        var["costume"] = '""'
                        code += "\n" + spaces + 'costume = correctur.ms('+ str(repeat_content(blocks, block, "COSTUME")) + f', "string", "res://scripts/{name}.gd", "switch costume to (!)")\n'
                        code += spaces + f'if str(costume).is_valid_int():\n'
                        code += spaces + f'\tmain.play(main.sprite_frames.get_animation_names()[int(costume) % main.sprite_frames.get_animation_names().size()])\n'
                        code += spaces + f'elif costume in main.sprite_frames.get_animation_names():\n'
                        code += spaces + f'\tmain.play(str(costume))\n'
                    case "looks_nextbackdrop":
                        code += spaces + f'main.play(main.sprite_frames.get_animation_names()[((main.sprite_frames.get_animation_names().find(main.get_tree()) + 1) % main.sprite_frames.get_animation_names().size())])\n'
                    case "looks_setStretch":
                        var["stretch_x"] = "0"
                        var["stretch_y"] = "0"
                        code += "\n" + spaces + 'stretch_x = correctur.ms('+ str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "set stretch to x: (!) y: ()")\n'
                        code += spaces + 'stretch_y = correctur.ms('+ str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "set stretch to x: () y: (!)")\n'
                        code += spaces + 'object.stretch = Vector2i(roundi(stretch_x),(stretch_y))\n'
                        code += spaces + 'animation.scale.x = object.size / 100 * object.size_x * object.stretch.x / 100\n'
                        code += spaces + 'animation.scale.y = object.size / 100 * object.stretch.y / 100\n'
                    case "looks_changesizeby":
                        var["size"] = '0'
                        code += "\n" + spaces + 'size = correctur.ms('+ str(repeat_content(blocks, block, "CHANGE")) + f', "float", "res://scripts/{name}.gd", "change size by (!)")\n'
                        code += spaces + 'if (object.size + size) < 0:\n'
                        code += spaces + '\tsize = 0\n'
                        code += spaces + 'animation.scale.x += size / 100 * object.size_x * object.stretch.x / 100\n'
                        code += spaces + 'animation.scale.y += size / 100 * object.stretch.y / 100 \n'
                    case "looks_setsizeto":
                        var["size"] = '0'
                        code += "\n" + spaces + 'size = correctur.ms('+ str(repeat_content(blocks, block, "SIZE")) + f', "float", "res://scripts/{name}.gd", "set size to (!)")\n'
                        code += spaces + 'if size < 0:\n'
                        code += spaces + '\tsize = 0\n'
                        code += spaces + 'animation.scale.x = size / 100 * object.size_x * object.stretch.x / 100\n'
                        code += spaces + 'animation.scale.y = size / 100 * object.stretch.y / 100\n'
                    case "looks_gotofrontback":
                        if block["fields"]["FRONT_BACK"] == "front":
                            code += "\n" + spaces + 'main.move_child(object, -1)\n'
                        else:
                            code += "\n" + spaces + 'main.move_child(object, 2)\n'
                    case "looks_goforwardbackwardlayers":
                        var["layer"] = 0
                        code += "\n" + spaces + 'layer = correctur.ms('+ str(repeat_content(blocks, block, "NUM")) + f', "float", "res://scripts/{name}.gd", "go (forward/backward) (!) layers")\n'
                        if str(repeat_content(blocks, block, "FORWARD_BACKWARD")) == "forward":
                            code += spaces + 'main.move_child(object, clamp(main.get_child_index(object) + layer + 2, 2, main.get_child_count() - 1))\n'
                        else:
                            code += spaces + 'main.move_child(object, clamp(main.get_child_index(object) - layer + 2, 2, main.get_child_count() - 1))\n'
                    case "looks_layersSetLayer":
                        var["layer"] = 0
                        code += "\n" + spaces + 'layer = correctur.ms('+ str(repeat_content(blocks, block, "NUM")) + f', "float", "res://scripts/{name}.gd", "go to (!) layers")\n'
                        code += "\n" + spaces + 'main.move_child(object, main.get_child_index(object) + layer + 2 if layer >= 0 else 2)'
                    case "looks_changeVisibilityOfSpriteShow":
                        var["sprite"] = '""'
                        code += "\n" + spaces + 'sprite = correctur.ms('+ str(repeat_content(blocks, block, "VISIBLE_OPTION")) + f', "string", "res://scripts/{name}.gd", "show (!)")\n'
                        code += spaces + 'if sprite == "_myself_":\n'
                        code += spaces + '\tobject.visible = true\n'
                        code += spaces + 'elif main.get_node_or_null(sprite):\n'
                        code += spaces + '\tmain.get_node_or_null(sprite).visible = true\n'
                    case "looks_changeVisibilityOfSpriteHide":
                        var["sprite"] = '""'
                        code += "\n" + spaces + 'sprite = correctur.ms('+ str(repeat_content(blocks, block, "VISIBLE_OPTION")) + f', "string", "res://scripts/{name}.gd", "hide (!)")\n'
                        code += spaces + 'if sprite == "_myself_":\n'
                        code += spaces + '\tobject.visible = false\n'
                        code += spaces + 'elif main.get_node_or_null(sprite):\n'
                        code += spaces + '\tmain.get_node_or_null(sprite).visible = false\n'
                    case "looks_changeeffectby":
                        var["effect"] = '0'
                        code += "\n" + spaces + 'effect = correctur.ms('+ str(repeat_content(blocks, block, "CHANGE")) + f', "float", "res://scripts/{name}.gd", "change effect [-----] by (!)")\n'
                        match block["fields"]["EFFECT"][0]:
                            case "COLOR":
                                code += spaces + 'mat.set_shader_parameter("color_shift", mat.get_shader_parameter("color_shift") + effect)\n'
                            case "MOSAIC":
                                code += spaces + 'mat.set_shader_parameter("mosaic", mat.get_shader_parameter("mosaic") + effect)\n'
                            case "RED":
                                code += spaces + 'mat.set_shader_parameter("red", mat.get_shader_parameter("red") + effect)\n'
                            case "GREEN":
                                code += spaces + 'mat.set_shader_parameter("green", mat.get_shader_parameter("green") + effect)\n'
                            case "BLUE":
                                code += spaces + 'mat.set_shader_parameter("blue", mat.get_shader_parameter("blue") + effect)\n'
                            case "FISHEYE":
                                code += spaces + 'mat.set_shader_parameter("fisheye", mat.get_shader_parameter("fisheye") + effect)\n'
                            case "WHIRL":
                                code += spaces + 'mat.set_shader_parameter("whirl", mat.get_shader_parameter("whirl") + effect)\n'
                            case "PIXELATE":
                                code += spaces + 'mat.set_shader_parameter("pixelate", mat.get_shader_parameter("pixelate") + effect)\n'
                            case "BRIGHTNESS":
                                code += spaces + 'mat.set_shader_parameter("brightness",mat.get_shader_parameter("brightness") + effect)\n'
                            case "GHOST":
                                code += spaces + 'mat.set_shader_parameter("ghost", mat.get_shader_parameter("ghost") + effect)\n'
                            case "SATURATION":
                                code += spaces + 'mat.set_shader_parameter("saturation", mat.get_shader_parameter("saturation") + effect)\n'
                            case "OPAQUE":
                                code += spaces + 'mat.set_shader_parameter("opaque ", mat.get_shader_parameter("opaque") + effect)\n'
                    case "looks_seteffect":
                        var["effect"] = '0'
                        code += "\n" + spaces + 'effect = correctur.ms('+ str(repeat_content(blocks, block, "VALUE")) + f', "float", "res://scripts/{name}.gd", "change effect [-----] by (!)")\n'
                        match block["fields"]["EFFECT"][0]:
                            case "COLOR":
                                code += spaces + 'mat.set_shader_parameter("color_shift", effect)\n'
                            case "MOSAIC":
                                code += spaces + 'mat.set_shader_parameter("mosaic", effect)\n'
                            case "RED":
                                code += spaces + 'mat.set_shader_parameter("red", effect)\n'
                            case "GREEN":
                                code += spaces + 'mat.set_shader_parameter("green", effect)\n'
                            case "BLUE":
                                code += spaces + 'mat.set_shader_parameter("blue", effect)\n'
                            case "FISHEYE":
                                code += spaces + 'mat.set_shader_parameter("fisheye", effect)\n'
                            case "WHIRL":
                                code += spaces + 'mat.set_shader_parameter("whirl", effect)\n'
                            case "PIXELATE":
                                code += spaces + 'mat.set_shader_parameter("pixelate", effect)\n'
                            case "BRIGHTNESS":
                                code += spaces + 'mat.set_shader_parameter("brightness", effect)\n'
                            case "GHOST":
                                code += spaces + 'mat.set_shader_parameter("ghost", effect)\n'
                            case "SATURATION":
                                code += spaces + 'mat.set_shader_parameter("saturation", effect)\n'
                            case "OPAQUE":
                                code += spaces + 'mat.set_shader_parameter("opaque ", effect)\n'
                    case "looks_cleargraphiceffects":
                        code += (
                            f'\n{spaces}mat.set_shader_parameter("color_shift", 0)\n'
                            f'{spaces}mat.set_shader_parameter("mosaic", 0)\n'
                            f'{spaces}mat.set_shader_parameter("red", 0)\n'
                            f'{spaces}mat.set_shader_parameter("green", 0)\n'
                            f'{spaces}mat.set_shader_parameter("blue", 0)\n'
                            f'{spaces}mat.set_shader_parameter("fisheye", 0)\n'
                            f'{spaces}mat.set_shader_parameter("whirl", 0)\n'
                            f'{spaces}mat.set_shader_parameter("pixelate", 0)\n'
                            f'{spaces}mat.set_shader_parameter("brightness", 0)\n'
                            f'{spaces}mat.set_shader_parameter("ghost", 0)\n'
                            f'{spaces}mat.set_shader_parameter("saturation", 0)\n'
                            f'{spaces}mat.set_shader_parameter("opaque", 0)\n'
                            f'{spaces}mat.set_shader_parameter("tint_color", Color(1, 1, 1))\n'
                        )
                    case "looks_setTintColor":
                        var["new_color"] = '""'
                        code += (
                            f'\n{spaces}new_color = Color("{str((repeat_content(blocks, block, "color")))}")\n'
                            f'\n{spaces}mat.set_shader_parameter("tint_color", new_color)\n'
                        )
                    #control-blocks
                    case "control_wait":
                        var["secs"] = 0
                        code += "\n" + spaces + 'secs = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "float", "res://scripts/{name}.gd", "wait (!) secs")\n'
                        code += spaces + 'await get_tree().create_timer(secs).timeout\n'
                    case "control_waitsecondsoruntil":
                        var["secs"] = 0
                        var["condition"] = "false"
                        code += "\n" + spaces + 'secs = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "float", "res://scripts/{name}.gd", "wait (!) secs or until true <>")\n'
                        code += spaces + 'secs = get_tree().create_timer(secs)\n'
                        code += spaces + 'while secs.time_left > 0:\n'
                        code += spaces + 'condition = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "bool", "res://scripts/{name}.gd", "wait () secs or until true <>")\n'
                        code += spaces + '\tif condition:\n'
                        code += spaces + '\t\tbreak\n'
                        code += spaces + '\tawait get_tree().process_frame\n'
                    case "control_repeat":
                        var["times"] = "0"
                        if "SUBSTACK" in block["inputs"]:
                            code += (
                                f'\n{spaces}times = correctur.ms(' + str(repeat_content(blocks, block, "TIMES")) + f', "float", "res://scripts/{name}.gd", "repeat (): {"{}"}")\n'
                                f'{spaces}for _{get_loop_varname(space)} in int(times):\n'
                                )
                            code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The content in the block 'Repeat (): {"{}"}' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case "control_if":
                        var["condition"] = "false"
                        if "SUBSTACK" in block["inputs"]:
                            if "CONDITION" in block["fields"]:
                                condition = repeat_content(blocks, block, "CONDITION")
                            else:
                                condition = '"true"'
                            code += (
                                f'\n{spaces}condition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "if <!> then: {"{}"}")\n'
                                f'{spaces}if condition:\n'
                                )
                            code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The content in the block 'if <> then: {"{}"}' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case "control_forever":
                        code += (
                            f'{spaces}while true:\n'
                            )
                        code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                    case "control_if_else":
                        var["condition"] = "false"
                        if "SUBSTACK" in block["inputs"]:
                            if "CONDITION" in block["inputs"]:
                                condition = repeat_content(blocks, block, "CONDITION")
                            else:
                                condition = '"true"'
                            code += (
                                f'\n{spaces}condition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "if <!> then: {"{}"} else: {"{}"}")\n'
                                f'{spaces}if condition:\n'
                                )
                            code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                            if "SUBSTACK2" in block["inputs"]:
                                code += f'\n{spaces}else:\n'
                                code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK2"][1]], space + 1, code, name))
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The content in the block 'if <> then: {"{}"} else: {"{}"}' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case "control_while":
                        var["condition"] = "false"
                        if "SUBSTACK" in block["inputs"]:
                            if "CONDITION" in block["inputs"]:
                                condition = repeat_content(blocks, block, "CONDITION")
                            else:
                                condition = '"true"'
                            code += (
                                f'\n{spaces}condition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "repeat while <!>: {"{}"}")\n'
                                f'{spaces}while condition:\n'
                                f'{spaces}\tcondition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "repeat while <!>: {"{}"}")\n'
                                )
                            code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The content in the block 'repeat while <>: {"{}"}' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case "control_repeat_until":
                        var["condition"] = "false"
                        if "SUBSTACK" in block["inputs"]:
                            if "CONDITION" in block["inputs"]:
                                condition = repeat_content(blocks, block, "CONDITION")
                            else:
                                condition = '"true"'
                            code += (
                                f'\n{spaces}condition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "repeat until <!>: {"{}"}")\n'
                                f'{spaces}while not(condition):\n'
                                f'{spaces}\tcondition = correctur.ms(' + str(condition) + f', "bool", "res://scripts/{name}.gd", "repeat until <!>: {"{}"}")\n'
                                )
                            code = str(convert_block(blocks, blocks[block["inputs"]["SUBSTACK"][1]], space + 1, code, name))
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The content in the block 'repeat until <>: {"{}"}' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case "event_broadcast":
                        
                        if "BROADCAST_INPUT" in block["inputs"]:
                            var["message"] = '""'
                            code += "\n" + spaces + 'message = correctur.ms('+ str(repeat_content(blocks, block, "BROADCAST_INPUT")) + f', "string", "res://scripts/{name}.gd", "broadcast (!)")\n'
                            code += spaces + 'main.broadcastlist[message] = 0\n'
                            code += spaces + 'main.broadcast = message\n'
                        #hier weiter machen
                        else:
                            code += (
                                f'''\n{spaces}print("WARNING: The message in the block 'broadcast' in the file 'res://scripts/{name}.gd' does not exist ''")\n'''
                                f'{spaces}correctur.help()\n'
                            )
                    case _:
                        code += spaces + f'''print("WARNING: unknown block '{block["opcode"]}'")\n'''
                    
            except:
                code += spaces + f'''print("WARNING: error by converting block '{block["opcode"]}'")\n'''
            if block["next"] == None:
                        break
            if "next" in blocks[block["next"]]:
                try:
                    block = blocks[block["next"]]
                except:
                    break
        code += "\n" + spaces + 'await get_tree().process_frame\n'
        

        return code
    code = convert_block(blocks, block, spaces, code, name)
    for key, value in var.items():
        code = f'var {key} = {value}\n' + str(code)
    return code
def repeat_content(blocks: dict, block: list, input_type: str):
    if "opcode" not in block:
        print("Error in Block: " + str(block))
        return 0
    print("Content of: " + str(block["opcode"]))
    if not( input_type in block["inputs"] or input_type in block["fields"]):
        print("input/field: " + str(input_type) + " is not in block: " + str(block["opcode"]))
        return 0
    value = block["inputs"][input_type] if input_type in block["inputs"] else block["fields"][input_type]
    print("The content of: " + str(input_type) + " is: " + str(value))
    match value[0]:
        case 1 | 2 | 3:
            if isinstance(value[1], list):
                try:
                    print(f"Content is a value/string: {str(value[1][1])}")
                    return(f'"{value[1][1]}"')
                except:
                    print(f"ERROR: Content doesn't exist in {str(value)}")
                    return 0
            else:
                try:
                    print(f"It is a variable Block: " + str(blocks[value[1]]["opcode"]))
                    match blocks[value[1]]["opcode"]:
                        
                        #operator blocks
                        case "operator_add":
                            return(f'op.add({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
                        case "operator_subtract":
                            return(f'op.sub({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
                        case "operator_multiply":
                            return(f'op.mul({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
                        case "operator_divide":
                            return(f'op.div({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
                        case "operator_random":
                            return(f'op.rand({repeat_content(blocks, blocks[value[1]], "FROM")},{repeat_content(blocks, blocks[value[1]], "TO")})')
                        case "operator_gt":
                            return(f'op.greater({repeat_content(blocks, blocks[value[1]], "OPERAND1")},{repeat_content(blocks, blocks[value[1]], "OPERAND2")})')
                        case "operator_lt":
                            return(f'op.less({repeat_content(blocks, blocks[value[1]], "OPERAND1")},{repeat_content(blocks, blocks[value[1]], "OPERAND2")})')
                        case "operator_equals":
                            return(f'op.equal({repeat_content(blocks, blocks[value[1]], "OPERAND1")},{repeat_content(blocks, blocks[value[1]], "OPERAND2")})')
                        case "operator_and":
                            return(f'op.and_({repeat_content(blocks, blocks[value[1]], "OPERAND1")},{repeat_content(blocks, blocks[value[1]], "OPERAND2")})')
                        case "operator_or":
                            return(f'op.or_({repeat_content(blocks, blocks[value[1]], "OPERAND1")},{repeat_content(blocks, blocks[value[1]], "OPERAND2")})')
                        case "operator_not":
                            return(f'op.not_({repeat_content(blocks, blocks[value[1]], "OPERAND")})')
                        case "operator_join":
                            return(f'str({repeat_content(blocks, blocks[value[1]], "STRING1")}) + str({repeat_content(blocks, blocks[value[1]], "STRING2")})')
                        case "operator_letter_of":
                            return(f'str({repeat_content(blocks, blocks[value[1]], "STRING")})[int({repeat_content(blocks, blocks[value[1]], "NUM")})]')
                        case "operator_length":
                            return(f'len(str({repeat_content(blocks, blocks[value[1]], "STRING")}))')
                        case "operator_contains":
                            return(f'str({repeat_content(blocks, blocks[value[1]], "STRING2")}).to_lower() in str({repeat_content(blocks, blocks[value[1]], "STRING1")})')
                        case "operator_mod":
                            return(f'op.mod({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
                        case "operator_round":
                            return(f'op.round_({repeat_content(blocks, blocks[value[1]], "NUM")})')
                        case "operator_mathop":
                            match block["fields"]["OPERATOR"]:
                                case "abs":
                                    return(f'op.abs_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "floor":
                                    return(f'op.floor_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "ceiling":
                                    return(f'op.ceilling_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "sqrt":
                                    return(f'op.sqrt_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "sin":
                                    return(f'op.sin_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "cos":
                                    return(f'op.cos_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "tan":
                                    return(f'op.tan_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "asin":
                                    return(f'op.asin_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "acos":
                                    return(f'op.acos_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "atan":
                                    return(f'op.atan_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "ln":
                                    return(f'op.ln_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "log":
                                    return(f'op.log_of({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "e ^":
                                    return(f'op.e_to_the_({repeat_content(blocks, blocks[value[1]], "NUM")})')
                                case "10 ^":
                                    return(f'op.ten_to_the_({repeat_content(blocks, blocks[value[1]], "NUM")})')
                        case "motion_goto_menu":
                            return(repeat_content(blocks, blocks[value[1]], "TO"))
                        case "motion_glideto_menu":
                            return(repeat_content(blocks, blocks[value[1]], "TO"))
                        case "motion_yposition":
                            return(f'(object.position.y * -1)')
                        case "motion_xposition":
                            return(f'object.position.x')
                        case "motion_direction":
                            return(f'object.direction')
                        case "motion_pointtowards_menu":
                            return(repeat_content(blocks, blocks[value[1]], "TOWARDS"))
                        case "looks_costume":
                            return(repeat_content(blocks, blocks[value[1]], "COSTUME"))
                        case "looks_stretchGetX":
                            return(f'object.stretch.x')
                        case "looks_stretchGetY":
                            return(f'object.stretch.y')
                        case "looks_getOtherSpriteVisible":
                            return(f'(main.get_node_or_null(str({repeat_content(blocks, blocks[value[1]], "VISIBLE_OPTION")})).visible if str({repeat_content(blocks, blocks[value[1]], "VISIBLE_OPTION")}) !=  "_myself_" else visible)')
                        case "looks_getOtherSpriteVisible_menu":
                            return(repeat_content(blocks, blocks[value[1]], "VISIBLE_OPTION"))
                        case "looks_changeVisibilityOfSprite_menu":
                            return(repeat_content(blocks, blocks[value[1]], "VISIBLE_OPTION"))
                        case "looks_layersGetLayer":
                            return(f'(get_index() + 1)')
                        case "looks_costumenumbername":
                            if blocks[value[1]]["fields"]["NUMBER_NAME"][0] == "number":
                               return ("(animation.sprite_frames.get_animation_names().find(animation.animation, 0) + 1)")
                            else:
                                return("animation.animation")
                        case "looks_backdropnumbername":
                            if blocks[value[1]]["fields"]["NUMBER_NAME"][0] == "number":
                               return ("main.sprite_frames.get_animation_names().find(main.animation, 0) + 1")
                            else:
                                return("main.animation")
                        case "looks_size":
                            return("object.size")
                        case "looks_tintColor":
                            return(f'mat.get_shader_parameter("tint_color", Color(1, 1, 1))')
                        case "looks_getEffectValue":
                            match block["fields"]["EFFECT"][0]:
                                case "COLOR":
                                    return('mat.get_shader_parameter("color_shift")')
                                case "MOSAIC":
                                    return('mat.get_shader_parameter("mosaic")')
                                case "RED":
                                    return('mat.get_shader_parameter("red")')
                                case "GREEN":
                                    return('mat.get_shader_parameter("green")')
                                case "BLUE":
                                    return('mat.get_shader_parameter("blue")')
                                case "FISHEYE":
                                    return('mat.get_shader_parameter("fisheye")')
                                case "WHIRL":
                                    return('mat.get_shader_parameter("whirl")')
                                case "PIXELATE":
                                    return('mat.get_shader_parameter("pixelate")')
                                case "BRIGHTNESS":
                                    return('mat.get_shader_parameter("brightness")')
                                case "GHOST":
                                    return('mat.get_shader_parameter("ghost")')
                                case "SATURATION":
                                    return('mat.get_shader_parameter("saturation")')
                                case "OPAQUE":
                                    return('mat.get_shader_parameter("opaque ")')
                        case _:
                            print("ERROR: Unnkown variable block: " + str(blocks[value[1]]["opcode"]))
                except:
                    print("ERROR: Unnkown content of Block: " + str(blocks[value[1]]))
                    return 0
        case _:
            print("probably just the value: " + str(value[0]))
            return(f'"{str(value[0])}"')
    return 0

def create_gd_script(blocks: dict, block_opcode: str, path: str, name: str, sprite_type: str) -> None:
    '''create the gd-script file of one stack blocks and saves this as "name" in path/folder "path"'''
    var = {}
    current_block = blocks[block_opcode]
            
    header = 'extends Node2D\n\nvar main = ""\nvar object = ""\nvar animation = ""\nvar mat = ""\n'
    main = "func _ready() -> void:\n"
    if sprite_type == "Background":
        header += 'var broadcast = ""\n'
        main += '\tmain = $"../.."\n\tobject = $"../.."\n\tanimation = $"../.."\n\tcall_deferred("_init_after_ready")\n\nfunc _init_after_ready():\n\tmat = animation.material as ShaderMaterial\n'
    else:
        main += '\tmain = $"../../../.."\n\tobject = $"../../.."\n\tanimation = $"../.."\n\tcall_deferred("_init_after_ready")\n\nfunc _init_after_ready():\n\tmat = animation.material as ShaderMaterial\n'
    privat_vars = []
    public_vars = []
    new = ""
    content = ""
    match current_block["opcode"]:
        case "event_whenflagclicked":
            content = convert_blocks(blocks, blocks[current_block["next"]], main, name, 1)
            new = ""
        case "event_whenthisspriteclicked":
            main += 'func _on_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:\n\tif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:\n'
            content = convert_blocks(blocks, blocks[current_block["next"]], main, name, 2)
            new = '[connection signal="input_event" from="Sprite/Area2D" to="Sprite/scripts/NAME" method="_on_event"]\n'
        case "event_whenkeypressed":
            if current_block["fields"]["KEY_OPTION"][0] == "any":
                main += 'func _input(event: InputEvent) -> void:\n\tif event is InputEventKey and not event.echo and event.pressed\n'
            else:
                main += 'func _input(event: InputEvent) -> void:\n\tif event is InputEventKey and not event.echo and event.pressed and event.keycode == ' + str(convert_key(current_block["fields"]["KEY_OPTION"][0])) + ':\n'
            content = convert_blocks(blocks, blocks[current_block["next"]], main, name, 2)
            new = '[connection signal="input_event" from="Sprite/Area2D" to="Sprite/scripts/NAME" method="_on_event"]\n'
        case "event_whenbackdropswitchesto":
            header += f'var current_costume = ""\nvar new_backdrop = "{current_block["fields"]["BACKDROP"][0]}"\n'
            main += '\tcurrent_costume = main.animation\n'
            main += 'func _process(_delta) -> void:\n\tif main.animation != current_costume:\n\t\tcurrent_costume = main.animation\n\t\tif main.animation == new_backdrop:\n'
            content = convert_blocks(blocks, blocks[current_block["next"]], main, name, 3)
        case "event_whenbroadcastreceived":
            header += 'var current_broadcast = ""\n'
            header += f'var my_broadcast = "{current_block["fields"]["BROADCAST_OPTION"][0]}"\n'
            header += 'var new_broadcast = false\n'
            main += '\tcurrent_broadcast = main.broadcast\n'
            main += 'func _process(_delta) -> void:\n\tif main.broadcast != current_broadcast:\n\t\tcurrent_broadcast = main.broadcast\n\t\tnew_broadcast = true\n\t\tmain.broadcastlist[my_broadcast] += 1'
            main += '\tif new_broadcast and main.broadcast == my_broadcast:\n\t\tnew_broadcast = false\n\t\tawait get_tree().process_frame\n\t\tmain.broadcast = ""\n'
            content = convert_blocks(blocks, blocks[current_block["next"]], main, name, 2)
            content += "\n\t\tmain.broadcastlist[my_broadcast] -= 1"
    open(f"{path}{name}.gd", "w").write(header + content)
    return new
def main_gd(variables, x, y, visible, size, direction, rotationStyle):
    code = f'''extends Node2D\n@export_group("Properties")\n@export_range(-179, 180) var direction: float = {direction - 90}\n@export var stretch = Vector2i(100, 100)\n@export var size = 100\nvar size_x = {-1 if rotationStyle == "left-right" and direction < 0 else 1}\n@export_enum("all around", "left-right", "don't rotate") var rotation_type: String = "{rotationStyle}"\n@export_group("Variables")\n'''
    for key, name in variables.items():
        code += f'''var {convert_string(name[0])} = {name[1]}'''
    code += (
            'func _on_ready() -> void:\n'
            '\tanimation.scale = Vector2(size / 100 * size_x * strech.x / 100, size / 100 * strech.y / 100)\n'
            '\tanimation.rotation = deg_to_rad(direction - 90)\n\n'
            #touching mouse
            'func is_mouse_over_hitbox() -> bool:\n'
            '\tvar mouse_pos = get_global_mouse_position()\n'
            '\treturn $CharacterBody2D/Area2D.get_polygon().has_point(\n'
            '\t\t$CharacterBody2D/CollisionPolygon2D.to_local(mouse_pos)\n'
            '\t)\n\n'
            #touching other Object
            'func is_touching_other_sprite(other_name: String) -> bool:\n'
            '\tvar other: Node2D = $"..".get_node_or_null(other_name)\n'
            '\tif other == null:\n'
            '\t\treturn false\n'
            '\tvar anim = $Sprite.animation\n'
            '\tvar poly: CollisionPolygon2D = $Sprite/Area2D.get_node_or_null("Collision-" + anim)\n'
            '\tif poly == null or not poly.visible:\n'
            '\t\treturn false\n\n'
            '\tvar other_sprite = other.get_node("Sprite")\n'
            '\tvar other_anim = other_sprite.animation\n'
            '\tvar other_poly: CollisionPolygon2D = other_sprite.get_node("Area2D").get_node_or_null("Collision-" + other_anim)\n'
            '\tif other_poly == null or not other_poly.visible:\n'
            '\t\treturn false\n\n'
            '\tvar shape = ConvexPolygonShape2D.new()\n'
            '\tshape.points = poly.polygon\n\n'
            '\tvar query = PhysicsShapeQueryParameters2D.new()\n'
            '\tquery.shape = shape\n'
            '\tquery.transform = poly.global_transform\n'
            '\tquery.collide_with_areas = true\n'
            '\tquery.collide_with_bodies = true\n\n'
            '\tvar hits = get_world_2d().direct_space_state.intersect_shape(query, 32)\n'
            '\tvar other_area = other_sprite.get_node("Area2D")\n\n'
            '\tfor hit in hits:\n'
            '\t\tif hit.get("collider") == other_area:\n'
            '\t\t\treturn true\n'
            '\treturn false\n'
        )
    return code

def background_gd():
    code = (
        ''
    )


def convert_string(input_str):
    result = []
    for char in input_str:
        if char.isalnum():
            result.append(char)
        else:
            result.append(f"_{ord(char)}_")
    return ''.join(result)