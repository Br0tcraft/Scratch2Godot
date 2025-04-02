##### **1. System Requirements**

- **Operating System:** Windows, macOS, Linux  
- **Python Version:** 3.x (recommended: 3.8 or higher)  
- **Required Dependencies:** OpenCV (`cv2`), NumPy, Pillow, etc.  

##### **2. Installation on Windows, Linux & macOS**  

###### **a) Install Python and Git**  

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

###### **b) Clone the Repository**  

Open a terminal and run:  

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/Scratch2Godot.git
cd Scratch2Godot
```

###### **c) Create a Virtual Environment and Install Dependencies**  

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

###### **d) Install OpenCV (`cv2`) Separately (if Errors Occur)**  

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

###### **e) Start the Tool**  

```bash
python main.py
```