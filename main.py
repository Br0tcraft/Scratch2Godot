import os, zipfile, uuid, json, logging
from utils.scene_creator import create_main_tscn
from utils.helpers import create_folders, init_logging


settings = {
    "project_name": "Scratchgame",
    "project_version": "1.0",
    "project_author": "Scratch",
    "project_description": "A Scratch project",
    "fps": "30", # Approx. 30fps in standard mode, ~60fps in turbo mode
    "debug": False,
    #"variable_style": "normal",  # "normal"; "large", "small", "just Text"
}


def Convert_game(input_file: str, settings: dict) -> str:
    """
    Convert a Scratch project (.sb3, .sb2, .sb) to a Godot-compatible format.

    This function attempts to open the file as a zip archive (as .sb3/.sb2 are zip-based)
    and locates a project.json inside. For older non-zip formats we provide clearer
    error messages and graceful failure.
    """
    init_logging(settings.get("debug", False))
    logger = logging.getLogger(__name__)

    if not os.path.exists(input_file):
        logger.error("File not found: %s", input_file)
        return ""

    temp_dir = f"temp/{uuid.uuid4().hex[:9]}"
    create_folders(temp_dir)

    # Try opening as a zip archive (works for .sb3 and .sb2 in most cases)
    try:
        with zipfile.ZipFile(input_file, 'r') as zip_file:
            try:
                with zip_file.open("project.json") as jf:
                    project_json = json.load(jf)
            except KeyError:
                logger.error("project.json not found in archive '%s'", input_file)
                return ""
            except json.JSONDecodeError:
                logger.error("Invalid JSON in project.json inside '%s'", input_file)
                return ""

            try:
                create_main_tscn(project_json, temp_dir, settings, zip_file)
            except Exception as e:
                logger.exception("Error while creating main scene: %s", e)
                return ""
        return temp_dir

    except zipfile.BadZipFile:
        logger.warning("File '%s' is not a zip archive; trying legacy handlers (sb)", input_file)
        # Attempt to read legacy .sb (Scratch 1.x) or other formats (best-effort)
        try:
            with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
                text = f.read()
                # Best-effort attempt to find JSON inside
                start = text.find('{')
                if start != -1:
                    try:
                        project_json = json.loads(text[start:])
                        create_main_tscn(project_json, temp_dir, settings, None)
                        return temp_dir
                    except Exception as e:
                        logger.error("Could not parse project JSON from legacy file: %s", e)
                        return ""
                else:
                    logger.error("Unsupported or corrupted Scratch file: %s", input_file)
                    return ""
        except Exception as e:
            logger.exception("Failed reading legacy Scratch file: %s", e)
            return ""


# Backwards compatibility convenience call
def Convert_game2(sb3_file: str, settings: dict) -> str:
    return Convert_game(sb3_file, settings)


if __name__ == "__main__":
    Convert_game(settings_file := "temp/ScratchProject.sb3", settings)
def Convert_game2(sb3_file: str, settings: dict) -> str:
    """
    Converts a Scratch .sb3 project to a Godot-compatible format.
    
    Args:
        sb3_file (str): Path to the .sb3 project file.
        settings (dict): Project settings such as name, fps, etc.
    
    Returns:
        str: Path to the generated temporary project folder.
    """
    temp_dir = f"temp/{uuid.uuid4().hex[:9]}"
    create_folders(temp_dir)
    with zipfile.ZipFile(sb3_file, 'r') as zip_file:
        with zip_file.open("project.json") as json_file:
            json_file = json.load(json_file)
            #create main_scene
            
            create_main_tscn(json_file, temp_dir, settings, zip_file)
    return(temp_dir)
Convert_game2("temp/ScratchProject.sb3", settings)