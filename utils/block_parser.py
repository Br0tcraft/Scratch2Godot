from types import SimpleNamespace

def repeat_block(blocks: dict, block: dict, space: int, code: SimpleNamespace, var: dict, path: str, name: str):
    match block["opcode"]:
                    #motion-blocks
        case "motion_movesteps":
            var["steps"] = 0
            code.main += "\n" + "\t" * space + 'steps = correctur.ms(' + str(repeat_content(blocks, block, "STEPS")) + f', "float", "res://scripts/{name}.gd", "move steps (!)")\n'
            code.main += "\t" * space + "object.position += Vector2(cos(object.direction) * steps, sin(object.direction) * steps)\n"
        case "motion_moveupdownsteps":
            var["rotate"] = 0
            var["steps"] = 0
            code.main += "\n" + "\t" * space + 'steps = correctur.ms(' + str(repeat_content(blocks, block, "STEPS")) + f', "float", "res://scripts/{name}.gd", "move (up/down) (!) steps"\n'
            code.main += "\t" * space + 'rotate = correctur.ms(' + str(repeat_content(blocks, block, "DIRECTION")) +f', "string", "res://scripts/{name}.gd", "move (!up/down) () steps"'
            code.main += "\t" * space + 'if rotate == "up":\n'
            code.main += "\t" * space + "\tobject.position += Vector2(cos(object.direction + 90) * steps, sin(object.direction + 90) * steps)\n"
            code.main += "\t" * space + 'elif rotate == "down":\n'
            code.main += "\t" * space + "\tobject.position += Vector2(cos(object.direction - 90) * steps, sin(object.direction - 90) * steps)\n"
        
        case "motion_turnright":
            var["spin"] = 0
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + 'spin = correctur.ms(' + str(repeat_content(blocks, block, "DEGREES")) + f', "float", "res://scripts/{name}.gd", "turn right (!)")\n'
            code.main += "\t" * space + 'object.direction += spin\n'
            code.main += "\t" * space + "\tdirection = op.rotate(object.direction)\n"
            code.main += "\t" * space + 'if rotationtype == "all around":\n'
            code.main += "\t" * space + "\tobject.rotation = deg_to_rad(direction)\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + "\tobject.rotation = 0\n"
        case "motion_turnleft":
            var["spin"] = 0
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + 'spin = correctur.ms(' + str(repeat_content(blocks, block, "DEGREES")) + f', "float", "res://scripts/{name}.gd", "turn left (!)")\n'
            code.main += "\t" * space + 'direction -= spin\n'
            code.main += "\t" * space + "\tdirection = op.rotate(direction)\n"
            code.main += "\t" * space + 'if rotationtype == "all around":\n'
            code.main += "\t" * space + "\tobject.rotation = deg_to_rad(direction)\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + "\tobject.rotation = 0\n"
        case "motion_gotoxy":
            var["Xnew"] = 0
            var["Ynew"] = 0
            code.main += "\n" + "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "go to x:(!) y:()")\n'
            code.main += "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "go to x:() y:(!)")\n'
            code.main += "\t" * space + "object.position = Vector2(Xnew, Ynew * -1.0)\n"
        case "motion_goto":
            var["goTo"] = "null"
            var["target_node"] = "null"
            code.main += "\n" + "\t" * space + "goTo = " + str(repeat_content(blocks, block, "TO")) + "\n"
            code.main += "\t" * space + f'if str(goTo) == "_mouse_":\n'
            code.main += "\t" * space + f"\tobject.position = get_global_mouse_position()\n"
            code.main += "\t" * space + f'elif str(goTo) == "_random_":\n'
            code.main += "\t" * space + f'\tobject.position = Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2))\n'
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + '\ttarget_node = get_node_or_null("/root/Main/" + str(goTo))\n'
            code.main += "\t" * space + '\tif target_node and target_node is Node2D:\n'
            code.main += "\t" * space + '\t\tobject.position = target_node.position\n'
            code.main += "\t" * space + '\telse:\n'
            code.main += "\t" * space + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "go to ()", str(goTo))\n'
        case "motion_glideto":
            var["secs"] = 0
            var["goTo"] = "null"
            var["tweenPos"] = "null"
            var["target_node"] = "null"
            code.main += "\n" + "\t" * space + "secs = correctur.ms(" + str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "glide (!) secs to ()")\n'
            code.main += "\t" * space + "goTo = " + str(repeat_content(blocks, block, "TO")) + "\n"
            code.main += "\t" * space + f'tweenPos = object.create_tween()\n'
            code.main += "\t" * space + f'if str(goTo) == "_mouse_":\n'
            code.main += "\t" * space + f'\ttweenPOS.tween_property(object, "position", get_global_mouse_position(), secs)\n'
            code.main += "\t" * space + f'elif str(goTo) == "_random_":\n'
            code.main += "\t" * space + f'\ttweenPOS.tween_property(object, "position", Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2)), secs)\n'
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + '\ttarget_node = get_node_or_null("/root/Main/" + str(goTo))\n'
            code.main += "\t" * space + '\tif target_node and target_node is Node2D:\n'
            code.main += "\t" * space + '\t\ttweenPOS.tween_property(object, "position", target_node.position, secs)\n'
            code.main += "\t" * space + '\telse:\n'
            code.main += "\t" * space + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "glide () secs to (!)", str(goTo))\n'
            code.main += "\t" * space + 'await tweenPos.finished\n'
        case "motion_glidesecstoxy":
            var["secs"] = 0
            var["Xnew"] = 0
            var["Ynew"] = 0
            var["tweenPos"] = "null"
            code.main += "\n" + "\t" * space + "secs = correctur.ms(" + str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "glide (!) secs to x:() y:()")\n'
            code.main += "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "glide () secs to x:(!) y:()")\n'
            code.main += "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "glide () secs to x:() y:(!)")\n'
            code.main += "\t" * space + "tweenPos = object.create_tween()\n"
            code.main += "\t" * space + 'tweenPos.tween_property(object, "position", Vector2(Xnew, Ynew * -1.0), secs)\n'
            code.main += "\t" * space + 'await tweenPos.finished\n'
        case "motion_pointtowards":
            var["lookat"] = '""'
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + "lookat = " + str(repeat_content(blocks, block, "TOWARDS")) + "\n"
            code.main += "\t" * space + f'if str(lookat) == "_mouse_":\n'
            code.main += "\t" * space + f"\tobject.look_at(get_global_mouse_position())\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + '\ttarget_node = object.get_parent().get_node_or_null(str(lookat))\n'
            code.main += "\t" * space + '\tif target_node and target_node is Node2D:\n'
            code.main += "\t" * space + '\t\tobject.look_at(lookat.global_position)\n'
            code.main += "\t" * space + '\telse:\n'
            code.main += "\t" * space + f'\t\tcorrectur.print_not_existing("res://scripts/{name}.gd", "point towards (!)", str(lookat))\n'
            code.main += "\t" * space + '''if rotationtype == "don't rotate":\n'''
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
        case "motion_pointindirection":
            var["rotate"] = 0
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + "rotate = correctur.ms(" + str(repeat_content(blocks, block, "DIRECTION")) + f', "float", "res://scripts/{name}.gd", "point in direction (!)")\n'
            code.main += "\t" * space + 'if rotationtype == "all around":\n'
            code.main += "\t" * space + "\tobject.rotation = deg_to_rad(rotate)\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + "\tobject.rotation = 0\n"
        case "motion_pointtowardsxy":
            var["Xnew"] = 0
            var["Ynew"] = 0
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "point towards x:(!) y:()")\n'
            code.main += "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "point towards x:() y:(!)")\n'
            code.main += "\t" * space + 'if rotationtype == "all around":\n'
            code.main += "\t" * space + "\tobject.look_at(Vector2(Xnew, Ynew * -1.0))\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + "\tobject.rotation = 0\n"
        case "motion_turnaround":
            code.main += "\n" + "\t" * space + 'object.rotation += PI\n'
        case "motion_changexby":
            var["Xnew"] = 0
            code.main += "\n" + "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "DX")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
            code.main += "\t" * space + "object.position.x += Xnew\n"
        case "motion_changeyby":
            var["Ynew"] = 0
            code.main += "\n" + "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "DY")) + f', "float", "res://scripts/{name}.gd", "change y by (!)")\n'
            code.main += "\t" * space + "object.position.y -= Ynew\n"
        case "motion_changebyxy":
            var["Ynew"] = 0
            var["Xnew"] = 0
            code.main += "\n" + "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "DY")) + f', "float", "res://scripts/{name}.gd", "change by x:() y: (!)")\n'
            code.main += "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "DX")) + f', "float", "res://scripts/{name}.gd", "change by x:(!) y:()")\n'
            code.main += "\t" * space + "object.position.x += Xnew\n"
            code.main += "\t" * space + "object.position.y -= Ynew\n"
        case "motion_setx":
            var["Xnew"] = 0
            code.main += "\n" + "\t" * space + "Xnew = correctur.ms(" + str(repeat_content(blocks, block, "X")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
            code.main += "\t" * space + "object.position.y = Xnew\n"
        case "motion_sety":
            var["Ynew"] = 0
            code.main += "\n" + "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
            code.main += "\t" * space + "object.position.y = Ynew * -1.0\n"
        case "motion_sety":
            var["Ynew"] = 0
            code.main += "\n" + "\t" * space + "Ynew = correctur.ms(" + str(repeat_content(blocks, block, "Y")) + f', "float", "res://scripts/{name}.gd", "change x by (!)")\n'
            code.main += "\t" * space + "object.position.y = Ynew * -1.0\n"
        case "motion_setrotationstyle":
            var["rotationtype"] = '"all around"'
            code.main += "\n" + "\t" * space + 'rotationtype = '+ str(repeat_content(blocks, block, "STYLE")) + '\n'
            code.main += "\t" * space + 'if rotationtype == "all around":\n'
            code.main += "\t" * space + "\tobject.rotation = deg_to_rad(object.direction)\n"
            code.main += "\t" * space + 'elif rotationtype == "left-right":\n'
            code.main += "\t" * space + "\tobject.rotation = 0\n"
            code.main += "\t" * space + "\tif object.direction > 0:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = 1\n"
            code.main += "\t" * space + "\telse:\n"
            code.main += "\t" * space + "\t\tobject.scale.x = -1\n"
            code.main += "\t" * space + "else:\n"
            code.main += "\t" * space + "\tobject.rotation = 0\n"
        case "motion_ifonedgebounce":
            var["size"] = 'Vector2(0 ,0)'
            var["cameraPos"] = 'Vector2(0 ,0)'
            code.main += "\n" + "\t" * space + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * object.scale / 2\n'
            code.main += "\t" * space + 'cameraPos = $"../../../../Camera2D".global_position\n'
            code.main += "\t" * space + 'if object.position.x - size.x < cameraPos.x - get_viewport().size.x / 2 or object.position.x + size.x > cameraPos.x + get_viewport().size.x / 2 or object.position.y - size.y < cameraPos.y - get_viewport().size.y / 2 or object.position.y + size.y > cameraPos.y + get_viewport().size.y / 2:\n'
            code.main += "\t" * space + '\tobject.direction = op.rotate(object.direction + 90)\n'
        case "motion_ifonspritebounce":
            var["sprite"] = '""'
            var["size"] = 'Vector2(0 ,0)'
            var["size2"] = 'Vector2(0 ,0)'
            code.main += "\n" + "\t" * space + 'sprite = correctur.ms("' + str(repeat_content(blocks, block, "SPRITE")) + f'", "string", "res://scripts/{name}.gd", "if touching (!) bounce")\n'
            code.main += "\t" * space + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * object.scale / 2\n'
            code.main += "\t" * space + 'if sprite == "_mouse_":\n'
            code.main += "\t" * space + '\tif get_global_mouse_position().x > object.position.x - size.x and get_global_mouse_position().x < object.position.x + size.x and get_global_mouse_position().y > object.position.y - size.y and get_global_mouse_position().y < object.position.y + size.y:\n'
            code.main += "\t" * space + '\t\tif "mouse" in object.last_touch and object.last_touch["mouse"] == "false":\n'
            code.main += "\t" * space + '\t\t\tobject.direction = op.rotate(object.direction + 180)\n'
            code.main += "\t" * space + '\t\tlast_touch["mouse] = "true"\n'
            code.main += "\t" * space + '\telse:\n'
            code.main += "\t" * space + '\t\tlast_touch["mouse"] = "false"\n'
            code.main += "\t" * space + 'elif sprite == "_random_":\n'
            code.main += "\t" * space + f'''\tprint("WARNING: In script 'res://scripts/{name}.gd', the converted block 'if touching () bounce' received an invalid value ('_random_')")\n'''
            code.main += "\t" * space + f'''\tprint("   This can happen because this block and the “point towards()” block use the same menu")\n'''
            code.main += "\t" * space + f'''\tprint( → to avoid errors, the block did nothing")\n'''
            code.main += "\t" * space + f'''\tcorrectur.help()\n'''
            code.main += "\t" * space + f'elif get_node_or_null(str(sprite)):\n'
            code.main += "\t" * space + f'\tsprite = main.get_node(str(sprite))\n'
            code.main += "\t" * space + f'\tsize = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * object.scale / 2\n'
            code.main += "\t" * space + f'\tsize2 = sprite.get_node("Sprite").sprite_frames.get_frame_texture(sprite.get_node("Sprite").animation, 0).get_size() * sprite.scale / 2\n'
            code.main += "\t" * space + f'\tif abs(object.position.x - sprite.position.x) < size.x + size2.x and abs(object.position.y - sprite.position.y) < size.y + size2.y:'
            code.main += "\t" * space + f'\t\tobject.direction = op.rotate(object direction + 90)'
        case "motion_move_sprite_to_scene_side":
            var["cameraPos"] = 'Vector2(0 ,0)'
            var["size"] = 'Vector2(0 ,0)'
            try:
                alignment = block["fields"]["ALIGNMENT"][0]
                code.main += "\n" + "\t" * space + 'size = animation.sprite_frames.get_frame_texture(animation.animation, 0).get_size() * object.scale / 2\n'
                code.main += "\t" * space + 'cameraPos = $"../../../../Camera2D".global_position\n'
                match alignment:
                    case "top-left":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                    case "top-right":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                    case "bottom-left":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                    case "bottom-right":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                    case "top":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + size.y)\n'
                    case "bottom":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y - size.y)\n'
                    case "left":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
                    case "right":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x - size.x, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
                    case "middle":
                        code.main += "\t" * space + ' object.position = Vector2(cameraPos.x - get_viewport().size.x / 2 + get_viewport().size.x / 2, cameraPos.y - get_viewport().size.y / 2 + get_viewport().size.y / 2)\n'
            except:
                code.main += "\n" + "\t" * space + '''print(Soemthing was wrong with the scratch-file. The Block 'move to stage [!]' has a not valid value)\n'''
                code.main += "\n" + "\t" * space + '''correctur.help()\n'''
        
        # look_blocks
        case "looks_sayforsecs":
            var["message"] = '""'
            var["secs"] = 0
            code.main += "\n" + "\t" * space + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "say (!) for () seconds")\n'
            code.main += "\n" + "\t" * space + 'secs = correctur.ms('+ str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "say () for (!) seconds")\n'
            code.main += "\t" * space + f'$"../../bubble".write(message, secs)\n'
        case "looks_say":
            var["message"] = '""'
            var["secs"] = 0
            code.main += "\n" + "\t" * space + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "say (!)")\n'
            code.main += "\t" * space + f'$"../../bubble".write(message, INF)\n'
        case "looks_thinkforsecs":
            var["message"] = '""'
            var["secs"] = 0
            code.main += "\n" + "\t" * space + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "think (!) for () seconds")\n'
            code.main += "\n" + "\t" * space + 'secs = correctur.ms('+ str(repeat_content(blocks, block, "SECS")) + f', "float", "res://scripts/{name}.gd", "think () for (!) seconds")\n'
            code.main += "\t" * space + f'$"../../bubble".write(message, secs, false)\n'
        case "looks_think":
            var["message"] = '""'
            var["secs"] = 0
            code.main += "\n" + "\t" * space + 'message = correctur.ms('+ str(repeat_content(blocks, block, "MESSAGE")) + f', "string", "res://scripts/{name}.gd", "think (!)")\n'
            code.main += "\t" * space + f'$"../../bubble".write(message, INF, false)\n'
        case "looks_show":
            code.main += "\n" + "\t" * space + 'object.show()\n'
        case "looks_hide":
            code.main += "\n" + "\t" * space + 'object.hide()\n'
        case "looks_switchcostumeto":
            var["costume"] = '""'
            code.main += "\n" + "\t" * space + 'costume = correctur.ms('+ str(repeat_content(blocks, block, "COSTUME")) + f', "string", "res://scripts/{name}.gd", "switch costume to (!)")\n'
            code.main += "\t" * space + f'if str(costume).is_valid_int():\n'
            code.main += "\t" * space + f'\tanimation.play(animation.sprite_frames.get_animation_names()[int(costume) % animation.sprite_frames.get_animation_names().size()])\n'
            code.main += "\t" * space + f'elif costume in animation.sprite_frames.get_animation_names():\n'
            code.main += "\t" * space + f'\tanimation.play(str(costume))\n'
        case "looks_nextcostume":
            code.main += "\t" * space + f'animation.play(animation.sprite_frames.get_animation_names()[((animation.sprite_frames.get_animation_names().find(animation.animation) + 1) % animation.sprite_frames.get_animation_names().size())])\n'
        case "looks_switchbackdropto":
            var["costume"] = '""'
            code.main += "\n" + "\t" * space + 'costume = correctur.ms('+ str(repeat_content(blocks, block, "COSTUME")) + f', "string", "res://scripts/{name}.gd", "switch costume to (!)")\n'
            code.main += "\t" * space + f'if str(costume).is_valid_int():\n'
            code.main += "\t" * space + f'\tget_tree().play(get_tree().sprite_frames.get_animation_names()[int(costume) % get_tree().sprite_frames.get_animation_names().size()])\n'
            code.main += "\t" * space + f'elif costume in get_tree().sprite_frames.get_animation_names():\n'
            code.main += "\t" * space + f'\tget_tree().play(str(costume))\n'
        case "looks_nextcostume":
            code.main += "\t" * space + f'get_tree().play(get_tree().sprite_frames.get_animation_names()[((get_tree().sprite_frames.get_animation_names().find(get_tree().get_tree()) + 1) % get_tree().sprite_frames.get_animation_names().size())])\n'
        case "looks_changesizeby":
            var["size"] = 'Vector2(0 ,0)'
            code.main += "\n" + "\t" * space + 'size = correctur.ms('+ str(repeat_content(blocks, block, "CHANGE")) + f', "float", "res://scripts/{name}.gd", "change size by (!)")\n'
            code.main += "\t" * space + 'object.scale.x += size\n'
            code.main += "\t" * space + 'object.scale.y += size\n'
        case "looks_setsizeto":
            var["size"] = 'Vector2(0 ,0)'
            code.main += "\n" + "\t" * space + 'size = correctur.ms('+ str(repeat_content(blocks, block, "SIZE")) + f', "float", "res://scripts/{name}.gd", "set size to (!)")\n'
            code.main += "\t" * space + 'object.scale.x = size\n'
            code.main += "\t" * space + 'object.scale.y = size\n'
        case "looks_gotofrontback":
            var["layer"] = 0
            code.main += "\n" + "\t" * space + 'layer = correctur.ms('+ str(repeat_content(blocks, block, "FRONT_BACK")) + f', "float", "res://scripts/{name}.gd", "go to (!) [front/back]")\n'
            code.main += "\t" * space + 'if layer == "front":\n'
            code.main += "\t" * space + '\tobject.get_parent().move_child(object, object.get_parent().get_child_count() - 1)\n'
            code.main += "\t" * space + 'elif layer == "back":\n'
            code.main += "\t" * space + '\tobject.get_parent().move_child(object, 0)()\n'
        case "looks_goforwardbackwardlayers":
            var["layer"] = 0
            var["forBack"] = '"forward"'
            code.main += "\n" + "\t" * space + 'layer = correctur.ms('+ str(repeat_content(blocks, block, "FORWARD_BACKWARD")) + f', "float", "res://scripts/{name}.gd", "go (!forward/backward) () layers")\n'
            code.main += "\t" * space + 'layer = correctur.ms('+ str(repeat_content(blocks, block, "NUM")) + f', "float", "res://scripts/{name}.gd", "go (forward/backward) (!) layers")\n'
            code.main += "\t" * space + 'if layer == "forward":\n'
            code.main += "\t" * space + '\tobject.get_parent().move_child(your_node, clamp(tobject.get_parent().get_child_index(your_node) - layer, 0, tobject.get_parent().get_child_count() - 1))\n'
            code.main += "\t" * space + 'elif layer == "backward":\n'
            code.main += "\t" * space + '\tobject.get_parent().move_child(your_node, clamp(tobject.get_parent().get_child_index(your_node) + layer, 0, tobject.get_parent().get_child_count() - 1))\n'
        case "control_wait":
            var["secs"] = 0
            code.main += "\n" + "\t" * space + 'secs = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "float", "res://scripts/{name}.gd", "wait () secs")\n'
            code.main += "\t" * space + 'await get_tree().create_timer(secs).timeout\n'
        case "control_waitsecondsoruntil":
            var["secs"] = 0
            var["condition"] = "false"
            code.main += "\n" + "\t" * space + 'secs = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "float", "res://scripts/{name}.gd", "wait (!) secs or until true <>")\n'
            code.main += "\t" * space + 'secs = get_tree().create_timer(secs)\n'
            code.main += "\t" * space + 'while secs.time_left > 0:\n'
            code.main += "\t" * space + 'condition = correctur.ms(' + str(repeat_content(blocks, block, "DURATION")) + f', "bool", "res://scripts/{name}.gd", "wait () secs or until true <>")\n'
            code.main += "\t" * space + '\tif condition:\n'
            code.main += "\t" * space + '\t\tbreak\n'
            code.main += "\t" * space + '\tawait get_tree().process_frame\n'
        case _:
            print("NOTHING: " + str(print(block["opcode"])))
    
    if block["next"] != None:
        repeat_block(blocks, blocks[block["next"]], space, code, var, path, name)
        return
        
    def_vars = ""
    for key, value in var.items():
        def_vars += f'var {key} = {value}\n'
    open(f"{path}{name}.gd", "w").write(code.header + def_vars + code.main)
    print("FERTIG")
    return
def repeat_content(blocks: dict, block: list, input_type: str):
    if not( input_type in block["inputs"] or input_type in block["fields"]):
        return 0
    value = block["inputs"][input_type] if input_type in block["inputs"] else block["fields"][input_type]
    #if input_type in block["inputs"]:
    #    if isinstance(value, list):
    #        try:
    #            return(str(value[1]))
    #        except:
    #            return 0
    #    else:
    #        return({repeat_content(blocks, blocks[value[1]], "TO")})
    match value[0]:
        case 1 | 2 | 3:
            if isinstance(value[1], list):
                try:
                    return(f'"{value[1][1]}"')
                except:
                    return 0
            else:
                try:
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
                            return(f'op.rand({repeat_content(blocks, blocks[value[1]], "NUM1")},{repeat_content(blocks, blocks[value[1]], "NUM2")})')
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
                            return(f'object.position.y')
                        case "motion_xposition":
                            return(f'object.position.x')
                        case "motion_direction":
                            return(f'rad2deg(object.direction)')
                        case "motion_pointtowards_menu":
                            return(repeat_content(blocks, blocks[value[1]], "TOWARDS"))
                
                except:
                    return 0
        case _:
            return(f'"{str(value[0])}"')
    return 0

def create_gd_script(blocks: dict, block_opcode: str, path: str, name: str) -> None:
    '''create the gd-script file of one stack blocks and saves this as "name" in path/folder "path"'''
    code = SimpleNamespace()
    var = {}
    current_block = blocks[block_opcode]
            
    code.header = 'extends Node2D\n\nvar main = ""\nvar object = ""\nvar animation = ""\n'
    code.main = "func _ready() -> void:\n"
    code.main += '\tmain = $"../../../.."\n\tobject = $"../../.."\n\tanimation = $"../.."\n'
    code.privat_vars = []
    code.public_vars = []
    match current_block["opcode"]:
        case "event_whenflagclicked":
            repeat_block(blocks, blocks[current_block["next"]], 1, code, var, path, name)