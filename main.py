import os, zipfile, uuid, json
from utils.scene_creator import create_main_tscn
from utils.helpers import create_folders


settings = {
    "project_name": "Scratchgame",
    "project_version": "1.0",
    "project_author": "Scratch",
    "project_description": "A Scratch project",
    "fps": "30", # Approx. 30fps in standard mode, ~60fps in turbo mode
    #"variable_style": "normal",  # "normal"; "large", "small", "just Text"
}


def Convert_game(sb3_file: str, settings: dict) -> str:
    """
    Converts a Scratch .sb3 project to a Godot-compatible format.
    
    Args:
        sb3_file (str): Path to the .sb3 project file.
        settings (dict): Project settings such as name, fps, etc.
    
    Returns:
        str: Path to the generated temporary project folder.
    """
    try:
        temp_dir = f"temp/{uuid.uuid4().hex[:9]}"
        create_folders(temp_dir)
        with zipfile.ZipFile(sb3_file, 'r') as zip_file:
            with zip_file.open("project.json") as json_file:
                json_file = json.load(json_file)
                #create main_scene
                try:
                    create_main_tscn(json_file, temp_dir, settings, zip_file)
                except Exception as error:
                    print(f"error by converting game: {error}")
        return(temp_dir)
    except FileNotFoundError:
        print("File not found:", sb3_file)
    except KeyError:
        print("project.json not found in .sb3 archive")
    except json.JSONDecodeError:
        print("Invalid JSON in project.json")

#Convert_game("temp/Fish.sb3", settings)
Convert_game("temp/ScratchProject.pmp", settings)