# Knarfscape — Dev Session Notes
**Date:** March 10, 2026
**Engine:** Godot 4.3 (GDScript)
**Repo:** https://github.com/Knarf224/Knarfscape.git
**Branch:** main

---

## Project Overview

**Knarfscape** is a 3D OSRS-inspired RPG being built in Godot 4.3. It is a personal game jam project with no hard deadline. The goal is a tutorial-style open world with RPG systems (skills, inventory, combat, quests) and an improving look and feel over time.

The world is a single scene (`scenes/world/main_world.tscn`) containing all world nodes. The game uses an autoload/singleton architecture for global state.

---

## Autoloads (Singletons)

These are globally available throughout all scripts — do not re-declare them as local variables:

| Autoload | Purpose |
|---|---|
| `GameManager` | Player stats, inventory, equipment, skills |
| `SaveSystem` | Save/load persistence |
| `QuestManager` | Quest tracking |
| `ChatLog` | In-world message log (use `ChatLog.add_message("text", "type")`) |
| `ItemsDatabase` | Static factory methods for creating Item instances |

---

## What Was Built Prior to This Session (Committed State)

By the start of this session, the following systems were already committed and working:

- **Player movement** — CharacterBody3D, third-person camera with SpringArm3D, mouse capture, running/walking
- **Combat** — melee attack with hitbox, attack cooldown, lock-on targeting
- **Skills system** — XP, levels, progress bars for: Attack, Defence, Strength, Woodcutting, Fishing, Cooking, Thieving
- **Inventory** — grid-based, stackable items, click to use/equip
- **Equipment UI** — slots for main hand, off hand, boots; click to equip from inventory
- **Equipment items** — Iron Longsword (trains Attack), Iron Shield (trains Defence), Leather Boots
- **HUD** — health bar, run energy, minimap placeholder
- **Skills panel** — all skills with XP bars (toggle with keybind)
- **Chat log** — scrollable in-world message feed
- **Enemy** — AI that chases and attacks player, health bar above head, respawns after death
- **Death system** — death screen, tombstone at death location, respawn at spawn point
- **NPC** — interactable character with dialogue
- **Resource nodes** — trees (woodcutting XP + logs), fishing spots (fishing XP + raw fish)
- **GLB asset overhaul** — rocks replaced with `rock_smallA.glb`, ground texture applied

---

## What Was Built This Session

### 1. Tree Asset Upgrade
- Replaced the old cylinder+sphere primitive trees with `tree_oak.glb` from the nature pack
- Trees were spawning at Y=1 (floating) due to the old mesh center offset — fixed to Y=0
- `Tree.tscn` uses `tree_oak.glb` at scale 3
- `tree.gd` uses a recursive `_find_mesh()` helper to locate the MeshInstance3D inside the imported GLTF node tree

### 2. Lootable Chest System
**Files:** `scenes/world/Chest.tscn`, `scenes/world/chest.gd`, `scenes/ui/chest_ui.tscn`, `scenes/ui/chest_ui.gd`

- Chest uses `chest.glb` from the kenney asset pack, scaled to 1.5x, with a BoxShape3D collision body
- `chest.gd` extends StaticBody3D, adds itself to the `"chests"` group on ready
- Contents defined as an array of `{item, quantity}` dicts — starts with: Tinderbox (x1), Lockpick (x3)
- Color applied via recursive `_apply_color()` function — sets `material_override` on all child MeshInstance3D nodes to a warm wood brown (`Color(0.55, 0.35, 0.15)`)
- Chest UI (`chest_ui.tscn` + `chest_ui.gd`) is a CanvasLayer panel — opens when player interacts with the chest, lists contents with individual "Take" buttons and a "Take All" button
- UI is added to `"chest_ui"` group so `chest.gd` can find it via `get_tree().get_first_node_in_group()`
- Closing the UI restores mouse capture

### 3. Campfire Cooking System
**Files:** `scenes/world/Fire.tscn`, `scenes/world/fire.gd`

- Campfire uses `campfire_stones.glb` from the nature pack at scale 3
- `fire.gd` extends StaticBody3D, adds itself to the `"fires"` group
- **Two states:**
  - **Unlit:** Requires tinderbox (kept, not consumed) + logs (consumed). Lights the fire, makes Flames MeshInstance3D and OmniLight3D visible
  - **Lit:** Requires raw fish in inventory. Cooks it — success chance = `min(0.5 + cooking_level * 0.02, 0.95)`. Success gives Cooked Fish + 30 Cooking XP. Burn gives +5 Cooking XP
- Visual feedback when lit: orange emissive SphereMesh flame + warm OmniLight3D glow

### 4. New Items Added to ItemsDatabase
**File:** `data/items_database.gd`

Four new static factory methods added:
- `create_tinderbox()` — Tool, id: `"tinderbox"`
- `create_lockpick()` — Tool, id: `"lockpick"`, stacks to 10
- `create_raw_fish()` — Resource, id: `"raw_fish"`, stacks to 50
- `create_cooked_fish()` — Consumable, id: `"cooked_fish"`, `heal_amount = 6`, stacks to 50

### 5. Item.gd — heal_amount Property
**File:** `scripts/item.gd`

Added `@export var heal_amount: int = 0` to support consumable items that restore HP.

### 6. Inventory UI — Eating Consumables
**File:** `scenes/ui/inventory_ui.gd`

In `_on_item_clicked()`, added handling for consumable items with `heal_amount > 0`:
- Calls `GameManager.stats.heal(float(item.heal_amount))`
- Removes one from inventory
- Logs the action to ChatLog with actual HP restored (capped at missing HP)

### 7. Player — Chest and Fire Interaction
**File:** `scenes/player/player.gd`

`_try_interact()` now scans `"chests"` and `"fires"` groups (in addition to existing resource nodes and NPCs), finds the closest interactable within range, and routes to the appropriate `try_interact(player)` call.

### 8. NPC House
**Files:** `scenes/world/House.tscn`

- Uses `structure.glb` + `structure-roof.glb` from the kenney asset pack
- Both scaled 3x; roof positioned at Y=3 above the base
- Collision provided by 5 `StaticBody3D` + `CylinderShape3D` nodes (one per wall: back, left, right, front-left, front-right)
- Front-center left open as the door passage
- Collision shapes were manually tuned in the Godot editor by the developer after the initial file was created
- House was placed in `main_world.tscn` by drag-and-drop in the Godot editor (not hand-edited into the .tscn file)
- Bed and barrel were planned as interior props but were removed from the final House.tscn during the editor editing pass — can be re-added later

---

## Setbacks and Hard-Won Lessons

These caused significant lost time this session. Document them carefully.

### 1. Kenney GLB Assets Have No Embedded Color
**Problem:** All kenney pack assets (castle walls, chest, structure, barrel, etc.) render completely white in Godot. The GLBs contain no `baseColorFactor` in their PBR materials.
**Nature pack assets DO have embedded colors** (campfire, rocks, trees, bed) and work fine.
**Solution:** Apply `material_override` in GDScript recursively to all MeshInstance3D children:
```gdscript
func _apply_color(node):
    if node is MeshInstance3D:
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.55, 0.35, 0.15)
        mat.metallic = 0.3
        mat.roughness = 0.7
        node.material_override = mat
    for child in node.get_children():
        _apply_color(child)
```
This is done in chest.gd. The house and barrel are currently still white — coloring is a future task.

### 2. main_world.tscn Is Extremely Fragile to Hand-Editing
**Problem:** Godot's `.tscn` format requires an exact `load_steps` count (= number of ext_resources + number of sub_resources + 1). It also has a strict UID system. Hand-editing this file caused repeated parse errors that made the game unloadable.

**Specific failure modes encountered:**
- **Wrong load_steps count** → parse error on open
- **Invented UIDs** in ext_resource lines → UID conflict if Godot had previously opened and stripped that scene's UID
- **CSGBox3D nodes inside a PackedScene** → they do not render when the PackedScene is instanced in another scene. Use `StaticBody3D + CollisionShape3D + BoxShape3D` for collision instead — these DO work correctly inside PackedScenes
- **Duplicate nodes** (adding a second NPC instead of updating the existing one) → runtime errors

**Solution:** Minimize hand-edits to main_world.tscn. Use the Godot editor for placing and positioning nodes whenever possible. When hand-edits are unavoidable, count load_steps extremely carefully and never invent UIDs — use path-only ext_resource references and let Godot assign UIDs on first open.

### 3. The Castle Detour
A significant portion of the session was spent attempting to add a kenney castle to the world to give the NPC a home. This went through multiple iterations:
- Initial castle: too large, all white, no collision
- Attempt to make hollow with CSGBox3D walls inside a PackedScene → walls didn't render
- Attempt to resize and add collision → multiple main_world.tscn parse errors
- Attempt to add a CSGBox3D stone house inline in main_world.tscn → same CSGBox3D-in-PackedScene problem
- Multiple git reverts required

**Outcome:** Castle was completely removed. The correct approach (a simple House.tscn with kenney structure.glb pieces and StaticBody3D collision) was identified and successfully implemented at the end of the session. The key insight is: **never use CSGBox3D for collision in a PackedScene** — always use StaticBody3D + CollisionShape3D + BoxShape3D.

---

## Current World Layout (approximate positions)

| Object | Position |
|---|---|
| Player spawn | (0, 0, 0) |
| NPC | (0.2, 0.5, -12) — should be moved inside house |
| House | Placed by editor — northwest of spawn near NPC |
| Rocks (x3) | West of spawn, around (-15, -0.38, 0) |
| Trees (x3) | South of spawn, around (0, 0, -17 to -20) |
| Fishing Spots (x2) | East of spawn, around (16, -0.5, 1) |
| Chest | (4, 0, -18) — near the trees |
| Campfire | (-2, 0, -24) — behind the trees |
| Enemy | (5, 0.5, 25) — north of spawn |

---

## Committed State (end of session)

All the following are committed and pushed to `main`:

```
3f23af2 Add NPC house with explorable interior and collision walls
02d16a7 Chest, campfire cooking system, tree GLB assets, consumable eating
82f9116 Asset overhaul - replace primitive shapes with GLB models, add ground/environment textures
b31688b Equipment system - longsword, shield, boots, equipment UI, click to equip, weapon visuals, attack style XP
c68ac13 Phase 7 - death system, tombstone, enemy health bars, enemy respawn, skills XP progress, chat log
```

---

## Suggested Next Steps (Priority Order)

### High priority — feel like a game
1. **Move NPC inside the house** — adjust NPC transform in Godot editor so it stands inside the doorway or just inside the front room
2. **Color the kenney assets** — apply the recursive `_apply_color()` pattern to House.tscn (structure, barrel) and any other white kenney pieces. Consider making a reusable autoload or scene script for this
3. **Sound effects** — even basic sounds (footsteps, attack hit, item pickup, fire crackle) make a massive difference to feel. Godot's `AudioStreamPlayer3D` can be attached to world objects
4. **Add more enemies** — a second enemy type or more instances of the existing one would make combat feel like a game loop rather than a demo

### Medium priority — content depth
5. **Woodcutting logs → chest or ground** — currently logs go to inventory but have no world source other than the fishing/skill loop. Make sure the woodcutting → campfire → cook → eat loop is fully functional end-to-end and test it
6. **Quest that ties everything together** — have the NPC give a quest: "Bring me a cooked fish." This connects the fishing, cooking, and NPC systems into a coherent tutorial
7. **More world detail** — flowers, grass patches, stumps, and mushrooms from the nature pack can be scattered around with no scripting needed. Purely visual but makes the world feel alive
8. **Path/road** — `ground_pathStraight.glb` and related nature pack pieces could create a path from spawn to the house

### Lower priority — polish
9. **Roof height fix** — the structure_roof Y position may need tweaking (currently set to Y=3, which was a guess)
10. **Lockpick mechanic** — lockpicks are in the chest but currently do nothing. A locked chest or door mechanic would complete that loop
11. **Minimap** — the HUD has a minimap placeholder; a real top-down camera or icon-based map would help navigation

---

## Key File Paths Reference

```
scenes/world/main_world.tscn     — main scene, edit in Godot editor not by hand
scenes/world/House.tscn          — NPC house
scenes/world/Chest.tscn          — lootable chest
scenes/world/Fire.tscn           — campfire
scenes/world/chest.gd            — chest interaction logic
scenes/world/fire.gd             — fire lighting + cooking logic
scenes/ui/chest_ui.tscn/.gd      — chest loot window
scenes/ui/inventory_ui.gd        — inventory click handling (eating consumables)
scenes/player/player.gd          — all player logic including _try_interact()
data/items_database.gd           — item factory methods (add new items here)
scripts/item.gd                  — Item class definition
assets/kenney/                   — kenney GLB assets (no embedded color)
assets/nature/GLTF format/       — nature pack GLB assets (have embedded color)
```
