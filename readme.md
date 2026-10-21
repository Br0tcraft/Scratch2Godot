# Scratch2Godot

A Godot editor plugin that converts Scratch (`.sb3`) projects into Godot scenes and GDScript.

Scratch2Godot brings Scratch projects into Godot without requiring you to rewrite everything by hand. The converter generates native Godot resources and GDScript that follows the original Scratch logic, making it possible to inspect the output and compare it with the source blocks.

This project is still in development. Some features are implemented, others are still missing, and some Scratch behavior differs from Godot.

## Example

A Scratch script like this:

```text
when green flag clicked
repeat (10)
    move (10) steps
    turn right (15) degrees
end
```

Produces GDScript along these lines:

```gdscript
func hat_whenflagclicked(ctx: ScriptContext) -> void:
    while not ctx.cancelled():
        for _i in int(round(S.num(10.0))):
            motion.move(S.num(10.0))
            motion.turn_right(S.num(15.0))
            if ctx.cancelled(): break
            await get_tree().process_frame
        await get_tree().process_frame
    return
```

The generated code uses runtime helpers for Scratch-specific behavior, so individual blocks do not translate directly into standalone GDScript statements.

## Feature support

### Supported block categories

| Category | Status |
|---|---|
| Motion, Looks, Sound, Events, Control, Sensing, Operators, Variables, Lists, My Blocks | Supported |
| Pen, Music, Video Sensing, other extensions | Not implemented |

Supported means the block categories are implemented in the converter. It does not guarantee that every project will behave exactly as it does in Scratch.

### Known limitations

**Not implemented or incomplete**

- **Ask and Answer:** These blocks are not implemented yet.
- **Sprite Effects:** I already have a shader for this, I just need to apply it to the sprites.
- **Runtime list editing:** Adding, removing, renaming, reordering, and changing list values at runtime is not supported.
- **Variable monitor:** Variables cannot yet be monitored live in the editor.
- **SVG text rendering:** Text in SVG costumes is not rendered correctly and requires a different rendering approach.
- **2D editor preview:** Sprites and costumes are not displayed in the editor viewport. Their images are loaded at runtime.
- **Extensions:** Scratch extensions are not supported yet. See [Extensions](#extensions).
- **Additional converter settings:** Fencing, miscellaneous limits, custom framerate, and username input are not available yet. See [Roadmap](#roadmap).

**Behavioral differences**

- **Runtime behavior:** Scratch logic is translated into GDScript rather than executed by the Scratch VM. Timing, edge cases, and other details may behave differently.
- **Variable and list identifiers:** Some Scratch names are not valid GDScript identifiers. The converter sanitizes them and preserves the original names in metadata where possible.
- **Cloud variables:** Scratch's original cloud infrastructure is not supported. Cloud variables use an alternative service instead.

For unexpected behavior, open an issue with a minimal reproduction and a description of the expected result.

## Requirements

- Godot 4.4
- A Scratch project in `.sb3` format

## Installation

You can install the plugin in an existing Godot project or clone the repository to work with the full project.

### Install the addon

1. Download the latest release or clone the repository.
2. Copy `addons/scratch_converter/` into the `res://addons/` directory of your Godot project. Create the directory if necessary.
3. Open the project in Godot.
4. Go to **Project → Project Settings → Plugins** and enable **Scratch Converter**.
5. Open the Scratch Converter dock.

If the dock does not appear, check that the plugin is enabled and that the project opens without errors.

### Clone the repository

```bash
git clone https://github.com/Br0tcraft/scratch-2-godot.git
```

Open the cloned project in Godot. It is already configured to use the plugin.

## Using the converter

1. Open the Scratch Converter dock.
2. Click **+** to open the conversion window.
3. Select a `.sb3` file.
4. Configure the conversion options.
5. Click **Transpile**.

Once conversion is complete, the converter generates the Godot resources and opens the root scene.

### Conversion options

| Category | Options |
|---|---|
| Runtime | Infinite clones, automatic startup, screen size, scaling mode |
| Player UI | Green flag and stop button visibility, colors, editable lists |
| Cloud variables | Server, local storage, ignore, or per-variable configuration |
| Build and conversion | Output path, temporary file cleanup, logging, overwrite behavior |

Enable **Log conversion process** for additional details in the Godot console.

## Cloud variables

The original Scratch cloud server is not supported. The default endpoint uses TurboWarp's cloud-variable server:

```text
wss://clouddata.turbowarp.org
```

Set the server URL and a project ID in the conversion window. The project ID keeps your cloud variables separate from those of other projects using the same server. If no ID is specified, the converter generates one by hashing the scene name.

| Mode | Behavior |
|---|---|
| Server | Connects to a cloud server and shares values. |
| Client | Stores values locally without network access. |
| Ignore | Treats cloud variables as ordinary local variables. |
| Advanced | Configures the mode individually for each variable. |

Server mode requires a network connection and a compatible server. The other modes work without one.

## Extensions

The following Scratch extensions are not implemented yet:

- Pen
- Music
- Video Sensing
- Other Scratch extensions

Pen is the highest-priority extension on the roadmap. If you need a specific extension, open an issue describing which blocks you need and how you intend to use them.

## Roadmap

Planned work is grouped below, roughly in priority order.

### Extensions

- Pen (highest priority)
- Other extensions based on requests

### Converter and runtime

- Ask and Answer blocks
- Runtime list editing: add, remove, rename, reorder, and change values
- Variable monitor
- Correct text rendering in SVG costumes
- Additional converter settings: fencing, miscellaneous limits, username input, and custom framerate, if per-scene framerate is feasible

### Editor and plugin

- Display sprite costumes in the 2D editor preview instead of loading them only at runtime
- Improve the control panel layout and add appropriate icons
- Add a list of previously converted projects and scenes to the dock
- Store the parsed Scratch structure, including blocks and sprites, so the dock can display the original Scratch project alongside the converted Godot scene and support reconversion
- Add language support, starting with English and German

### Documentation

- Expand the documentation, including a reference for writing custom GDScript against the generated output
- Add a translation table mapping Scratch blocks to GDScript

## Development background

Scratch2Godot is a rewrite of an earlier project with the same name. The original version was a Python script that generated Godot project files and `.tscn` scenes.

The current version is a native Godot editor plugin that uses the editor APIs directly and fits into a standard Godot project workflow.

## Contributing

Bug reports, feature requests, and pull requests are welcome.

Before opening an issue, check whether it has already been reported.

For bug reports, include as much of the following as possible:

- The original `.sb3` file, ideally reduced to a minimal reproduction
- The generated Godot resources or scripts
- The expected behavior and what actually happened
- Relevant errors from the Godot console

For feature requests, describe the intended use case.

For pull requests, keep changes focused and follow the existing GDScript style.