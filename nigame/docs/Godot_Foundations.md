# Step 2 — Godot foundations

## Project setup

Open `project.godot` with the installed Godot 4.4.1 editor. This is already a 2D GDScript project; the Mono edition also supports GDScript. The viewport is now 1280×720 with `canvas_items` stretch and nearest texture filtering. Resize the game window to see how the canvas scales. The normal entry scene remains `Scenes/test_world.tscn`, referenced by path so it also resolves on a fresh checkout without the generated UID cache.

`Scenes/foundations/Blank.tscn` is an empty Node2D scene for the foundations acceptance check. Open it and press F6 (Run Current Scene). Press F5 to run the existing player/HUD prototype. Stop the game before editing. The blank scene still runs project AutoLoads; it deliberately has no player or HUD.

## Hands-on editor practice

These are exercises to complete in the editor, not claims that you have already learned the topics. Use a new practice scene under `Scenes/foundations/` so experiments are separate from the prototype.

1. **Scenes, nodes, and Inspector:** open `Scenes/player.tscn`. Select its CharacterBody2D root, Sprite2D, and CollisionShape2D in the Scene dock. Find the texture, position, and rectangle shape in the Inspector. Use the FileSystem dock to locate their files. A saved scene is a reusable node tree; the world instances the player and HUD scenes.
2. **Signals and groups:** inspect the existing button's `pressed` connection in `UI/HUD.tscn` and its `_on_button_pressed` method in `UI/hud.gd`. In your practice scene, add a Button and connect its `pressed` signal to a method that prints a message. In the Node dock, add a node to a `practice_targets` group; retrieve it with `get_tree().get_nodes_in_group("practice_targets")`. A signal announces something happened; a group lets you find related nodes.
3. **Typed GDScript:** attach a script to your practice Node2D and try the snippet below. Run with F6 and inspect Output. Change the array values and run again. `_ready()` runs after the node and its children enter the scene tree.

```gdscript
extends Node2D

var reward: int = 100
var names: Array[String] = ["Neighbour", "Vendor"]
var stock: Dictionary = {"water": 2}

func total_pay(deliveries: int) -> int:
	return deliveries * reward

func _ready() -> void:
	print(names[0], ": ", total_pay(2), " naira; water: ", stock["water"])
```

4. **Bodies, areas, and collision:** inspect the player's rectangle shape. A CharacterBody2D moves through `velocity` and `move_and_slide()`; a StaticBody2D with a CollisionShape2D makes a wall. In the practice scene, instance the player and add a wall. Add an Area2D with its own shape, enable monitoring, and connect `body_entered` to print the entering body's name. Bodies block; areas detect overlap. Collision layers say what an object is; masks say what it detects. Use Debug → Visible Collision Shapes while running. Full movement and wall verification belong to Step 3.
5. **TileMapLayer and TileSet:** add a TileMapLayer to the practice scene. Create a TileSet in its Inspector, set tile size to 32×32, and inspect the TileSet editor. A TileSet defines reusable tiles and their collision data; a TileMapLayer places those tiles on a grid. Painting requires an atlas texture with known permission, so use your own placeholder before importing external art. Use separate layers for ground and obstacles in the later street milestone.
6. **Resources and instances:** save this script as `Scenes/foundations/PracticeJob.gd`, then use FileSystem → Create New → Resource to make an instance of `PracticeJob`. Save it as a `.tres` and edit the exported pay in the Inspector. Resources hold reusable data; scenes hold node trees. You can use `var job = preload("res://Scenes/foundations/PracticeJob.tres")` to load the saved resource from a script. For a scene, `var player = preload("res://Scenes/player.tscn").instantiate()` creates nodes; `add_child(player)` puts them in the tree. The existing world already uses saved player and HUD scene instances.

```gdscript
extends Resource
class_name PracticeJob

@export var job_id: String = "practice_delivery"
@export var pay: int = 100
```

7. **Input and debugger:** open Project → Project Settings → Input Map and inspect built-in `ui_left`, `ui_right`, `ui_up`, and `ui_down`, which the current player uses. WASD and interaction actions are Step 3 work. Run the prototype and inspect Output and Debugger for errors; the Remote scene tree shows live nodes, including AutoLoads.

## Git

The existing repository is at `C:/laragon/www/GAME_GODOT`, one directory above this project. Do not initialize a nested repository. This project's `.gitignore` already ignores `.godot/` and Android generated files. Keep `.gd.uid` and asset `.import` configuration files; they are different from the generated `.godot/` cache.

There are unrelated changes in sibling projects. Review and commit only this project's milestone files; avoid staging the entire parent repository. No global Git trust settings need to change for this setup.

## Completion checklist

- Technical checks are recorded in the roadmap after validation.
- Complete the seven hands-on exercises above, then check off the five learning tasks in Stage 01.
- A headless startup check verifies loading and runtime errors; it does not establish visual layout, input feel, or completion of these exercises.
