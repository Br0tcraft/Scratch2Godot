import os, zipfile, uuid, json
from utils.scene_creator import create_main_tscn
from utils.helpers import create_folders


settings = {
    "project_name": "Scratchgame",
    "project_version": "1.0",
    "project_author": "Scratch",
    "project_description": "A Scratch project",
    "variable_style": "normal",  # "normal"; "large", "small", "just Text"
}


def Convert_game(sb3_file: str, settings: dict) -> str:
    temp_dir = f"temp/{uuid.uuid4().hex[:9]}"
    create_folders(temp_dir)
    with zipfile.ZipFile(sb3_file, 'r') as zip_file:
        with zip_file.open("project.json") as json_file:
            json_file = json.load(json_file)
            #create main_scene
            create_main_tscn(json_file, temp_dir, settings, zip_file)
    return(temp_dir)

Convert_game("temp/ScratchProject.sb3", settings)