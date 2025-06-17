## Scratch2Godot - Work in Progress
Scratch2Godot is a converter that transforms Scratch projects (.sb3) into Godot projects. 

![image](resources/icon.svg)

An example Scratch game and its converted Godot version can be found in the temp folder.

Important Note: This tool is still in development and not fully functional. Some features are experimental or not yet implemented.

### Features (Current & Planned)

**Implemented:**

- Detection and import of all sprites and stage backgrounds  
- Full support for motion blocks (from both Scratch and PenguinMod)  
- Support for all standard Scratch "Looks" blocks  
  - Partial support for PenguinMod "Looks" extensions  
  - Standard speech bubbles are supported; special effects like stylized bubbles are not yet implemented  
  - Visual effects exist but may not work exactly as in Scratch  
- Full support for all operator blocks  
- Partial implementation of control blocks:  
  - `wait (1) seconds`  
  - `wait (1) seconds or until <>`  
  - `repeat (10)`  
  - `forever`  
  - `if <> then {}`  
  - `if <> then {} else {}`  
  - `repeat until <> {}`  
  - `while <> {}`  
- Limited support for event blocks:  
  - `when green flag clicked`  
  - `when this sprite clicked`  
  - `when (key) pressed`  
  - *(not yet tested)* `when backdrop switches to ()`
  - `when I receive []`
  - `boradcast ()`
  - `boradcast () and wait`

**In Development / Planned:**

- Full support for event handling *(except for* `when [loudness] > ()`*), currently under development and not yet stable.*
- Complete support for additional block categories (e.g. sensing, variables)
- Improved error handling, debugging output, and overall conversion stability  

### **1. System Requirements**

- **Operating System:** Windows, macOS, Linux  
- **Python Version:** 3.x (recommended: 3.8 or higher)  
- **Godot Version:** 4.x (recommended 4.3)
- **Required Dependencies:** OpenCV (`cv2`), NumPy, Pillow, etc.  

### **2. Installation on Windows, Linux & macOS**  

#### **a) Install Python and Git**  

If not already installed:  

- **Windows:** [Download Python](https://www.python.org/downloads/) and install it (make sure to check _"Add Python to PATH"_).  
- **Linux/macOS:** Python is usually preinstalled. If not:  

```bash
# Ubuntu/Debian
sudo apt install python3 python3-pip  

# Arch
sudo pacman -S python python-pip  

# macOS (with Homebrew)
brew install python3  
```

- **Install Git** (to clone the repository):  

```bash
# Windows: Download and install Git from https://git-scm.com/downloads

# Ubuntu/Debian
sudo apt install git  

# Arch
sudo pacman -S git  

# macOS (Homebrew)
brew install git  
```

#### **b) Clone the Repository**  

Open a terminal and run:  

```bash
git clone https://github.com/br0tcraft/Scratch2Godot.git
cd Scratch2Godot
```

#### **c) Create a Virtual Environment and Install Dependencies**  

1. Create a virtual environment (optional but recommended):  

```bash
# macOS/Linux
python -m venv venv  
source venv/bin/activate  

# Windows
venv\Scripts\activate  
```

2. Install dependencies:  

```bash
pip install -r requirements.txt  
```

#### **d) Install OpenCV (`cv2`) Separately (if Errors Occur)**  
OpenCV (cv2) may not be the most optimal choice for this project, but it was chosen for its ease of integration. Future updates might explore other options.

If `cv2` doesn't work directly, install it manually:  

```bash
pip install opencv-python
```

If there are issues on Linux/macOS:  

```bash
# Ubuntu/Debian
sudo apt install python3-opencv  

# macOS (Homebrew)
brew install opencv  
```

### **3. Usage Instructions**

To start the tool and convert a Scratch project to a Godot project, follow these steps:

#### **a) Prepare Your Scratch Project (SB3 File)**
    
- Make sure your Scratch project file (with the extension `.sb3`) is accessible.
        
- Rename it to `ScratchProject.sb3` and place it inside the `temp` folder.
        
- Your folder structure should look like this:
        
         Scratch2Godot/
        ├── main.py
        ├── temp/
        │     └── ScratchProject.sb3
        ├── utils/
        └── resources/
- Alternatively, you can specify the path to any SB3 file directly.
        
#### **b) Project Structure and Output**
    
- The resulting Godot project will be stored in the `temp` folder.
        
- You can open the generated project in Godot by navigating to the `temp` folder and selecting the main project file (`project.godot`).
        
#### **c) Customization**
    
- You can adjust the **project settings** by modifying the `settings` dictionary inside `main.py`:
        
```
settings = {     
"project_name": "Scratchgame",     
"project_version": "1.0",     
"project_author": "Scratch",     
"project_description": "A Scratch project",     
"fps": "30"
}
```
        
- These settings will be applied during the conversion process.
