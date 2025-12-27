import random, string, os, shutil, math
try:
    from unidecode import unidecode
except Exception:
    def unidecode(x):
        return x

from types import SimpleNamespace
from utils.block_parser import create_gd_script, main_gd, background_gd
from utils.file_handling import jpg_to_png, svg_to_png, resize_png_half, collision_shape2d, import_file
from utils.helpers import normalize_to_latin_godot_style


FONT_MAPPING = {
            'Sans Serif': 'NotoSans-Medium.ttf',
            'Serif': 'SourceSerifPro-Regular.ttf',
            'Handwriting': 'handlee-regular.ttf',
            'Marker': 'Knewave.ttf',
            'Curly': 'Griffy-Regular.ttf',
            'Pixel': 'Grand9K-Pixel.ttf',
            'Scratch': 'ScratchSavers_b2.ttf'
        }

def create_main_tscn(json_file: dict, temp_dir: str, settings, zip_file: dict) -> None:
    '''
    Create the scene files (.tscn) for the Scene and every Object

    the json_file is the project.json file from the extract .sb3 file

    the temp_dir is the folder where the content will created
    '''
    #create project.godot. The file you have to chose to open the project in godot
    config = f"""config_version=5\n\n[application]\n\nconfig/name="{settings["project_name"]}"\nconfig/description="{settings["project_description"]}"\nconfig/version="{settings["project_version"]}"\nrun/main_scene="res://main.tscn"\nconfig/features=PackedStringArray("4.3", "Mobile")\nrun/max_fps={settings["fps"]}\nconfig/icon="res://icon.svg"\n[display]\n\nwindow/size/viewport_width=480\nwindow/size/viewport_height=360\nwindow/stretch/mode="canvas_items"\n\n[rendering]\n\nrenderer/rendering_method="mobile" """
    open(f'{temp_dir}/Godotgame/project.godot', "w", encoding="utf-8").write(config)
    main_scene = SimpleNamespace()
    main_scene.load_steps = f'[gd_scene load_steps={len(json_file["targets"])*3} format=3 uid="uid://{"".join(random.choices(string.digits + string.ascii_lowercase, k=13))}"]\n'
    main_scene.resource = '\n[ext_resource type="Shader" path="res://assets/effects.gdshader" id="1_mjccp"]\n[ext_resource type="SpriteFrames" uid="uid://-Stage" path="res://costumes/Animation-Stage.tres" id="id-frame-Stage"]\n\n[ext_resource type="Script" path="res://scripts/BACKGROUND.gd" id="id_Background-script"]\n'
    main_scene.scripts = ""
    main_scene.standart = ('\n\n[sub_resource type="ShaderMaterial" id="ShaderMaterial_rg8s7"]\n'
                        'shader = ExtResource("1_mjccp")\n'
                        f'shader_parameter/color_shift = 0.0\n'
                        f'shader_parameter/fisheye = 0.0\n'
                        f'shader_parameter/whirl = 0.0\n'
                        f'shader_parameter/pixelate = 0.0\n'
                        f'shader_parameter/mosaic = 0.0\n'
                        f'shader_parameter/brightness = 0.0\n'
                        f'shader_parameter/ghost = 0.0\n'
                        f'shader_parameter/sprite_size = 10.0\n'
                        f'shader_parameter/saturation = null\n'
                        f'shader_parameter/opaque = null\n'
                        f'shader_parameter/red = null\n'
                        f'shader_parameter/green = null\n'
                        f'shader_parameter/blue = null\n'
                        f'shader_parameter/tint_color = Color(1, 1, 1, 1)\n'
                        )
    
                            
    for sprite in json_file["targets"]:
        sprite["name"] = unidecode(str(sprite["name"])).encode('utf-8').decode('utf-8')
        if sprite["isStage"]:
            main_scene.background = f'\n\n[node name="Background" type="AnimatedSprite2D"]\nz_index = -4096\nsprite_frames = ExtResource("id-frame-Stage")\nanimation = &"{sprite["costumes"][sprite["currentCostume"]]["name"]}"\nscript = ExtResource("id_Background-script")\nmaterial = SubResource("ShaderMaterial_rg8s7")\n\n'
            main_scene.background += f'\n[node name="Camera2D" type="Camera2D" parent="."]\nposition = Vector2(0, 0)\n'
            background_gd(f"{temp_dir}/Godotgame/", sprite)
            costume = SimpleNamespace()
            animation = SimpleNamespace()
            animation.start = f'[gd_resource type="SpriteFrames" load_steps={len(sprite["costumes"])} format=3 uid="uid://frames-Stage"]'
            animation.ext = ""
            animation.res = "[resource]\nanimations = ["
            for costumes in sprite["costumes"]:
                costume.name = costumes["md5ext"]
                if (costume.name).lower().endswith("png"):
                    zip_file.extract(costume.name, f'{temp_dir}/Godotgame/')
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file(costume.name, costume.name[:-4]))
                elif (costume.name).lower().endswith("jpg"):
                    jpg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.jpg', '.png')}")
                    os.remove(f'{temp_dir}/Godotgame/{costume.name}')
                    #update costume name
                    costume.name = (costume.name).replace('.jpg', '.png')
                    #save costume
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file((costume.name).replace('.jpg', '.png'), costume.name[:-4]))
            
                
                elif (costume.name).lower().endswith('.svg'):
                    svg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.svg', '.png')}", FONT_MAPPING)
                    os.remove(f'{temp_dir}/Godotgame/{costume.name}')
                    #update costume name
                    costume.name = (costume.name).replace('.svg', '.png')
                    #save costume
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file((costume.name).replace('.svg', '.png'), costume.name[:-4]))
                animation.ext += f'\n[ext_resource type="Texture2D" uid="uid://{costume.name[:-4]}" path="res://{costume.name}" id="id_{costume.name[:-4]}"]'
                frames = f'"duration": 1.0,\n"texture": ExtResource("id_{costume.name[: -4]}")'
                ani = f'],\n"loop": false,\n"name": &"{costumes["name"]}",\n"speed": 0.0'
                animation.res += '{\n"frames":[{\n' + frames + '\n}' + ani + '\n}, '
            animation.res = animation.res[: -2]
            animation.res += "]"
            final_animation = animation.start + "\n" + animation.ext + "\n\n" + animation.res
            open(f'{temp_dir}/Godotgame/costumes/Animation-{sprite["name"]}.tres', "w", encoding="utf-8").write(final_animation)
            main_scene.nodes = f"""\n[node name="scripts" type="Node2D" parent="."]"""
            topLevels = []
            blocks = sprite["blocks"]
            topLevels = [opcode for opcode, block in blocks.items() if block["topLevel"] and not block["shadow"] and block["next"]]
            signals = "\n\n"
            for topLevel in topLevels:
                name = blocks[topLevel]["opcode"] + "-" + "".join(random.choices(string.digits + string.ascii_lowercase, k=5))
                main_scene.resource += f"""\n[ext_resource type="Script" path="res://scripts/{sprite["name"]}-{name}.gd" id="id_{sprite["name"]}-{name}"]"""
                main_scene.nodes += f"""\n[node name="{name}" type="Node2D" parent="scripts"]"""
                main_scene.nodes += f"""\nscript = ExtResource("id_{sprite["name"]}-{name}")"""
                signals += create_gd_script(blocks, topLevel, f"{temp_dir}/Godotgame/scripts/", f"{sprite['name']}-{name}", "Background")
        else:
            create_Object_scene(sprite, temp_dir, zip_file)
            main_scene.resource += f'[ext_resource type="PackedScene" uid="uid://sprite-{sprite["name"]}" path="res://sprites/{sprite["name"]}.tscn" id="id-sprite-{sprite["name"]}"]\n'
            main_scene.nodes += f'\n[node name="{sprite["name"]}" parent="." instance=ExtResource("id-sprite-{sprite["name"]}")]\nposition = Vector2({sprite["x"]}, {sprite["y"] * -1})\n'
    open(f'{temp_dir}/Godotgame/main.tscn', "w", encoding="utf-8").write(main_scene.load_steps + main_scene.resource + main_scene.standart + main_scene.background + main_scene.nodes + signals)
    shutil.copy("resources/icon.svg", f'{temp_dir}/Godotgame/icon.svg')
    shutil.copy("resources/controll.gd", f'{temp_dir}/Godotgame/assets/controll.gd')
    shutil.copy("resources/correctures.gd", f'{temp_dir}/Godotgame/assets/correctures.gd')
    shutil.copy("resources/effects.gdshader", f'{temp_dir}/Godotgame/assets/effects.gdshader')
    shutil.copy("resources/bubble.tscn", f'{temp_dir}/Godotgame/assets/bubble.tscn')
    shutil.copy("resources/bubble.gd", f'{temp_dir}/Godotgame/scripts/bubble.gd')

def create_Object_scene(sprite_data: dict, temp_dir: str, zip_file) -> str:
    '''
    make a scene file (.tscn) just for one s(prite that is created in Scratch
    '''
    sprite_data["name"] = unidecode(str(sprite_data["name"])).encode('utf-8').decode('utf-8')
    sprite = SimpleNamespace()
    animation = SimpleNamespace()

    # Sprite and animation identifiers
    sprite.uid = f'uid://sprite-{sprite_data["name"]}'
    sprite.spriteframe = f'frames-{sprite_data["name"]}'
    sprite.uidframe = f'uid://{"".join(random.choices(string.digits, k=19))}'

    # Animation resource header
    animation.start = f'[gd_resource type="SpriteFrames" load_steps={len(sprite_data["costumes"])} format=3 uid="{sprite.uidframe}"]'

    # Scene load steps and resources
    sprite.load_steps = f'[gd_scene load_steps=2 format=3 uid="{sprite.uid}"]\n\n'
    sprite.resource = (
        f'[ext_resource type="SpriteFrames" uid="{sprite.uidframe}" path="res://costumes/Animation-{sprite_data["name"]}.tres" id="{sprite.spriteframe}"]\n'
        f'[ext_resource type="Script" path="res://scripts/sprite-{sprite_data["name"]}.gd" id="id_sprite-{sprite_data["name"]}"]\n'
        f'[ext_resource type="Shader" path="res://assets/effects.gdshader" id="id_shader_{sprite_data["name"]}"]'
    )

    # Animation resource content
    animation.res = "[resource]\nanimations = ["

    # Node definitions
    sprite.nodes = (
        #shader settings
        f'\n[sub_resource type="ShaderMaterial" id="ShaderMaterial_{sprite_data["name"]}"]\n'
        f'shader = ExtResource("id_shader_{sprite_data["name"]}")\n'
        f'shader_parameter/color_shift = 0.0\n'
        f'shader_parameter/fisheye = 0.0\n'
        f'shader_parameter/whirl = 0.0\n'
        f'shader_parameter/pixelate = 0.0\n'
        f'shader_parameter/mosaic = 0.0\n'
        f'shader_parameter/brightness = 0.0\n'
        f'shader_parameter/ghost = 0.0\n'
        f'shader_parameter/sprite_size = 10.0\n'
        f'shader_parameter/saturation = null\n'
        f'shader_parameter/opaque = null\n'
        f'shader_parameter/red = null\n'
        f'shader_parameter/green = null\n'
        f'shader_parameter/blue = null\n'
        f'shader_parameter/tint_color = Color(1, 1, 1, 1)\n'
        # nodes
        f'\n[node name="{sprite_data["name"]}" type="Node2D"]\n'
        f'script = ExtResource("id_sprite-{sprite_data["name"]}")\n'
        f'[node name="Sprite" type="AnimatedSprite2D" parent="."]\n'
        f'sprite_frames = ExtResource("{sprite.spriteframe}")\n'
        f'animation = &"{normalize_to_latin_godot_style(sprite_data["costumes"][sprite_data["currentCostume"]]["name"])}"\n'
        f'material = SubResource("ShaderMaterial_{sprite_data["name"]}")\n'
        f'[node name="Area2D" type="Area2D" parent="Sprite"]'
    )
    costume = SimpleNamespace()
    animation.ext = ""
    animation.res = "[resource]\nanimations = ["
    for costume_data in sprite_data["costumes"]:
        costume.name = unidecode(str(costume_data.get("md5ext", f'{costume_data["assetId"]}.{costume_data["dataFormat"]}'))).encode('utf-8').decode('utf-8')
        # Extract and process costume files
        if costume.name.lower().endswith("png"):
            png_path = f"{temp_dir}/Godotgame/{costume.name}"
            resize_png_half(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), png_path)
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file(costume.name, costume.name[:-4]))
        elif costume.name.lower().endswith("jpg"):
            png_path = f"{temp_dir}/Godotgame/{costume.name.replace('.jpg', '.png')}"
            jpg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), png_path)
            os.remove(f'{temp_dir}/Godotgame/{costume.name}')
            costume.name = costume.name.replace('.jpg', '.png')
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file(costume.name, costume.name[:-4]))
        elif costume.name.lower().endswith("svg"):
            png_path = f"{temp_dir}/Godotgame/{costume.name.replace('.svg', '.png')}"
            svg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), png_path, FONT_MAPPING)
            os.remove(f'{temp_dir}/Godotgame/{costume.name}')
            costume.name = costume.name.replace('.svg', '.png')
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w", encoding="utf-8").write(import_file(costume.name, costume.name[:-4]))

        # Add collision shape
        sprite.nodes += f'\n[node name="Collision-{normalize_to_latin_godot_style(costume_data["name"])}" type="CollisionPolygon2D" parent="Sprite/Area2D"]'
        costume.collision = collision_shape2d(f"{temp_dir}/Godotgame/{costume.name}")
        sprite.nodes += f'\npolygon = {costume.collision}'
        if sprite_data["costumes"][sprite_data["currentCostume"]] != costume_data:
            sprite.nodes += f'\ndisabled = true'
        else:
            sprite.nodes += f'\ndisabled = false'
        # Add animation frames
        animation.ext += f'\n[ext_resource type="Texture2D" uid="uid://{costume.name[:-4]}" path="res://{costume.name}" id="id_{costume.name[:-4]}"]'
        animation.res += (
            '{\n"frames": [{\n'
            f'"duration": 1.0,\n"texture": ExtResource("id_{costume.name[:-4]}")\n'
            '}],\n'
            f'"loop": false,\n"name": &"{normalize_to_latin_godot_style(costume_data["name"])}",\n"speed": 0.0\n'
            '}, '
        )
    # Add bubble and scripts
    sprite.resource += '\n[ext_resource type="PackedScene" uid="uid://bubble" path="res://assets/bubble.tscn" id="bubble"]'
    sprite.nodes += '\n[node name="bubble" parent="." instance=ExtResource("bubble")]'
    sprite.nodes += '\nvisible = false'
    sprite.nodes += '\nscale = Vector2(0.6, 0.6)'
    sprite.nodes += '\n[node name="scripts" type="Node2D" parent="Sprite"]'

    # Generate main script
    open(f'{temp_dir}/Godotgame/scripts/sprite-{sprite_data["name"]}.gd', "w", encoding="utf-8").write(main_gd(sprite_data["variables"], sprite_data["x"], sprite_data["y"], sprite_data["visible"], sprite_data["size"], sprite_data["direction"], sprite_data["rotationStyle"]))

    # Process top-level blocks
    top_levels = [opcode for opcode, block in sprite_data["blocks"].items() if block["topLevel"] and not block["shadow"] and block["next"]]
    signals = "\n\n"
    for top_level in top_levels:
        name = f'{sprite_data["blocks"][top_level]["opcode"]}-{"".join(random.choices(string.digits + string.ascii_lowercase, k=5))}'
        sprite.resource += f'\n[ext_resource type="Script" path="res://scripts/{sprite_data["name"]}-{name}.gd" id="id_{sprite_data["name"]}-{name}"]'
        sprite.nodes += f'\n[node name="{name}" type="Node2D" parent="Sprite/scripts"]\nscript = ExtResource("id_{sprite_data["name"]}-{name}")'
        signals += create_gd_script(sprite_data["blocks"], top_level, f"{temp_dir}/Godotgame/scripts/", f"{sprite_data['name']}-{name}", "Background" if sprite_data["isStage"] else "Sprite").replace("NAME", name)
    sprite.nodes += '[connection signal="body_entered" from="Sprite/Area2D" to="." method="_body_entered"]\n[connection signal="input_event" from="Sprite/Area2D" to="." method="_input_event"]'
    # Finalize animation and scene files
    animation.res = animation.res.rstrip(", ") + "]"
    final_scene = sprite.load_steps + sprite.resource + "\n" + sprite.nodes + signals
    final_animation = animation.start + "\n" + animation.ext + "\n\n" + animation.res
    open(f'{temp_dir}/Godotgame/sprites/{sprite_data["name"]}.tscn', "w", encoding="utf-8").write(final_scene)
    open(f'{temp_dir}/Godotgame/costumes/Animation-{sprite_data["name"]}.tres', "w", encoding="utf-8").write(final_animation)
    return