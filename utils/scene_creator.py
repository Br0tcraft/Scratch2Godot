import random, string, os, shutil, math
from types import SimpleNamespace
from utils.block_parser import create_gd_script
from utils.file_handling import jpg_to_png, svg_to_png, collision_shape2d, import_file

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
    config = f"""config_version=5\n\n[application]\n\nconfig/name="{settings["project_name"]}"\nconfig/description="{settings["project_description"]}"\nconfig/version="{settings["project_version"]}"\nrun/main_scene="res://main.tscn"\nconfig/features=PackedStringArray("4.3", "Mobile")\nconfig/icon="res://icon.svg"\n[display]\n\nwindow/size/viewport_width=480\nwindow/size/viewport_height=360\n\n[rendering]\n\nrenderer/rendering_method="mobile" """
    open(f'{temp_dir}/Godotgame/project.godot', "w").write(config)
    main_scene = SimpleNamespace()
    main_scene.load_steps = f'[gd_scene load_steps={len(json_file["targets"])*3} format=3 uid="uid://{"".join(random.choices(string.digits + string.ascii_lowercase, k=13))}"]\n'
    main_scene.resource = '\n[ext_resource type="SpriteFrames" uid="uid://-Stage" path="res://costumes/Animation-Stage.tres" id="id-frame-Stage"]\n'
    main_scene.scripts = ""
    main_scene.standart = f'\n\n[node name="Camera2D" type="Camera2D" parent="."]\nposition = Vector2(0, 0)\n'
    main_scene.nodes = ""
    for sprite in json_file["targets"]:
        if sprite["isStage"]:
            print("TRue")
            main_scene.background = f'\n\n[node name="Background" type="AnimatedSprite2D"]\nz_index = -4096\nsprite_frames = ExtResource("id-frame-Stage")\nanimation = &"{sprite["costumes"][sprite["currentCostume"]]["name"]}"\n\n'
            costume = SimpleNamespace()
            animation = SimpleNamespace()
            animation.start = f'[gd_resource type="SpriteFrames" load_steps={len(sprite["costumes"])} format=3 uid="uid://frames-Stage"]'
            animation.ext = ""
            animation.res = "[resource]\nanimations = ["
            for costumes in sprite["costumes"]:
                costume.name = costumes["md5ext"]
                if (costume.name).lower().endswith("png"):
                    zip_file.extract(costume.name, f'{temp_dir}/Godotgame/')
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file(costume.name, costume.name[:-4]))
                elif (costume.name).lower().endswith("jpg"):
                    jpg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.jpg', '.png')}")
                    os.remove(f'{temp_dir}/Godotgame/{costume.name}')
                    #update costume name
                    costume.name = (costume.name).replace('.jpg', '.png')
                    #save costume
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file((costume.name).replace('.jpg', '.png'), costume.name[:-4]))
            
                
                elif (costume.name).lower().endswith('.svg'):
                    svg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.svg', '.png')}", FONT_MAPPING)
                    os.remove(f'{temp_dir}/Godotgame/{costume.name}')
                    #update costume name
                    costume.name = (costume.name).replace('.svg', '.png')
                    #save costume
                    open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file((costume.name).replace('.svg', '.png'), costume.name[:-4]))
                animation.ext += f'\n[ext_resource type="Texture2D" uid="uid://{costume.name[:-4]}" path="res://{costume.name}" id="id_{costume.name[:-4]}"]'
                frames = f'"duration": 1.0,\n"texture": ExtResource("id_{costume.name[: -4]}")'
                ani = f'],\n"loop": false,\n"name": &"{costumes["name"]}",\n"speed": 0.0'
                animation.res += '{\n"frames":[{\n' + frames + '\n}' + ani + '\n}, '
            animation.res = animation.res[: -2]
            animation.res += "]"
            final_animation = animation.start + "\n" + animation.ext + "\n\n" + animation.res
            open(f'{temp_dir}/Godotgame/costumes/Animation-{sprite["name"]}.tres', "w").write(final_animation)
            main_scene.nodes += f"""\n[node name="scripts" type="Node2D" parent="."]"""
            topLevels = []
            blocks = sprite["blocks"]
            for opcode, block in blocks.items():
                if block["topLevel"] == True and block["shadow"] == False and block["next"] != None:
                    topLevels.append(opcode)
            for topLevel in topLevels:
                name = blocks[topLevel]["opcode"] + "-" + "".join(random.choices(string.digits + string.ascii_lowercase, k=5))
                main_scene.resource += f"""\n[ext_resource type="Script" path="res://scripts/{sprite["name"]}-{name}.gd" id="id_{sprite["name"]}-{name}"]"""
                main_scene.nodes += f"""\n[node name="{name}" type="Node2D" parent="scripts"]"""
                main_scene.nodes += f"""\nscript = ExtResource("id_{sprite["name"]}-{name}")"""
                create_gd_script(blocks, topLevel, f"{temp_dir}/Godotgame/scripts/", f"{sprite['name']}-{name}")
        else:
            create_Object_scene(sprite, temp_dir, zip_file)
            main_scene.resource += f'[ext_resource type="PackedScene" uid="uid://sprite-{sprite["name"]}" path="res://sprites/{sprite["name"]}.tscn" id="id-sprite-{sprite["name"]}"]\n'
            main_scene.nodes += f'\n[node name="{sprite["name"]}" parent="." instance=ExtResource("id-sprite-{sprite["name"]}")]\nposition = Vector2({sprite["x"]}, {sprite["y"] * -1})\nrotation = {math.radians(sprite["direction"] - 90)}\nz_index = {sprite["layerOrder"]}'
    open(f'{temp_dir}/Godotgame/main.tscn', "w").write(main_scene.load_steps + main_scene.resource + main_scene.background + main_scene.standart + main_scene.nodes)
    shutil.copy("resouces/icon.svg", f'{temp_dir}/Godotgame/icon.svg')
    shutil.copy("resouces/controll.gd", f'{temp_dir}/Godotgame/assets/controll.gd')
    shutil.copy("resouces/correctures.gd", f'{temp_dir}/Godotgame/assets/correctures.gd')
    shutil.copy("resouces/effects.gdshader", f'{temp_dir}/Godotgame/assets/effects.gdshader')
    shutil.copy("resouces/bubble.tscn", f'{temp_dir}/Godotgame/assets/bubble.tscn')
    shutil.copy("resouces/bubble.gd", f'{temp_dir}/Godotgame/scripts/bubble.gd')
#[node name="Node2D" parent="CanvasLayer/VBoxContainer/AspectRatioContainer" instance=ExtResource("3_7axgv")]
#position = Vector2(0, 3)

def create_Object_scene(sprite_data: dict, temp_dir: str, zip_file) -> str:
    '''
    make a scene file (.tscn) just for one s(prite that is created in Scratch
    '''
    sprite = SimpleNamespace()
    animation = SimpleNamespace()
    sprite.uid = f'uid://sprite-{sprite_data["name"]}'
    sprite.spriteframe = f'frames-{sprite_data["name"]}'
    sprite.uidframe = f'uid://{"".join(random.choices(string.digits, k=19))}'
    animation.start = f'[gd_resource type="SpriteFrames" load_steps={len(sprite_data["costumes"])} format=3 uid="{sprite.uidframe}"]'
    sprite.load_steps = f'[gd_scene load_steps=2 format=3 uid="{sprite.uid}"]\n\n'
    sprite.resource = f"""[ext_resource type="SpriteFrames" uid="{sprite.uidframe}" path="res://costumes/Animation-{sprite_data["name"]}.tres" id="{sprite.spriteframe}"]"""
    animation.ext = ""
    animation.res = "[resource]\nanimations = ["
    sprite.nodes = f"""[node name="{sprite_data['name']}" type="Node2D"]"""
    sprite.nodes += f"""[node name="Sprite" type="AnimatedSprite2D" parent="."]\n"""
    sprite.nodes += f"""\nsprite_frames = ExtResource("{sprite.spriteframe}")"""
    sprite.nodes += f"""\nanimation = &"{sprite_data["costumes"][sprite_data["currentCostume"]]["name"]}" """
    sprite.nodes += f"""\n[node name="CharacterBody2D" type="CharacterBody2D" parent="Sprite"]"""
    costume = SimpleNamespace()
    for costumes in sprite_data["costumes"]:
        if "md5ext" in costumes:
            costume.name = costumes["md5ext"]
            
        else:
            print(costumes)
            costume.name = costumes["assetId"] + "." +costumes["dataFormat"]
        if (costume.name).lower().endswith("png"):
            zip_file.extract(costume.name, f'{temp_dir}/Godotgame/')
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file(costume.name, costume.name[:-4]))
        elif (costume.name).lower().endswith("jpg"):
            jpg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.jpg', '.png')}")
            os.remove(f'{temp_dir}/Godotgame/{costume.name}')
            #update costume name
            costume.name = (costume.name).replace('.jpg', '.png')
            #save costume
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file((costume.name).replace('.jpg', '.png'), costume.name[:-4]))
        elif (costume.name).lower().endswith('.svg'):
            svg_to_png(zip_file.extract(costume.name, f'{temp_dir}/Godotgame/'), f"{temp_dir}/Godotgame/{(costume.name).replace('.svg', '.png')}", FONT_MAPPING)
            os.remove(f'{temp_dir}/Godotgame/{costume.name}')
            #update costume name
            costume.name = (costume.name).replace('.svg', '.png')
            #save costume
            open(f"{temp_dir}/Godotgame/{costume.name}.import", "w").write(import_file((costume.name).replace('.svg', '.png'), costume.name[:-4]))
        sprite.nodes += f'''\n[node name="Collision-{costumes["name"]}" type="CollisionPolygon2D" parent="Sprite/CharacterBody2D"]'''
        #create collision shape
        costume.collision = collision_shape2d(f"{temp_dir}/Godotgame/{costume.name}")
        sprite.nodes += f'\npolygon = {costume.collision}'
        animation.ext += f'\n[ext_resource type="Texture2D" uid="uid://{costume.name[:-4]}" path="res://{costume.name}" id="id_{costume.name[:-4]}"]'
        frames = f'"duration": 1.0,\n"texture": ExtResource("id_{costume.name[: -4]}")'
        ani = f'],\n"loop": false,\n"name": &"{costumes["name"]}",\n"speed": 0.0'
        animation.res += '{\n"frames":[{\n' + frames + '\n}' + ani + '\n}, '
    sprite.resource += '''\n[ext_resource type="PackedScene" uid="uid://bubble" path="res://assets/bubble.tscn" id="bubble"]'''
    sprite.nodes += '''\n[node name="bubble" parent="." instance=ExtResource("bubble")]'''
    sprite.nodes += '''\nvisible = false'''
    sprite.nodes += '''\n[node name="scripts" type="Node2D" parent="Sprite"]'''
    topLevels = []
    blocks = sprite_data["blocks"]
    for opcode, block in blocks.items():
        if block["topLevel"] == True and block["shadow"] == False and block["next"] != None:
            topLevels.append(opcode)
    for topLevel in topLevels:
        name = blocks[topLevel]["opcode"] + "-" + "".join(random.choices(string.digits + string.ascii_lowercase, k=5))
        sprite.resource += f"""\n[ext_resource type="Script" path="res://scripts/{sprite_data["name"]}-{name}.gd" id="id_{sprite_data["name"]}-{name}"]"""
        sprite.nodes += f"""\n[node name="{name}" type="Node2D" parent="Sprite/scripts"]"""
        sprite.nodes += f"""\nscript = ExtResource("id_{sprite_data["name"]}-{name}")"""
        create_gd_script(blocks, topLevel, f"{temp_dir}/Godotgame/scripts/", f"{sprite_data['name']}-{name}")
        
    animation.res = animation.res[: -2]
    animation.res += "]"
    final_scene = sprite.load_steps + sprite.resource  + "\n" + sprite.nodes
    final_animation = animation.start + "\n" + animation.ext + "\n\n" + animation.res
    open(f'{temp_dir}/Godotgame/sprites/{sprite_data["name"]}.tscn', "w").write(final_scene)
    open(f'{temp_dir}/Godotgame/costumes/Animation-{sprite_data["name"]}.tres', "w").write(final_animation)
    return


