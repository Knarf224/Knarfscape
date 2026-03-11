# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Knarfscape** is a 3D OSRS-inspired RPG built in Godot 4.3 (GDScript, Forward Plus renderer). It features skill-based progression, equipment, inventory, quests, resource gathering, and enemy combat.

## Running the Game

Open `project.godot` in Godot 4.3+ and press F5 to run, or use the Godot CLI:
```
godot --path . scenes/world/main_world.tscn
```

There is no build step, linter, or test suite — this is a Godot project edited through the Godot editor.

## Architecture

### Autoloads (Global Singletons)

Defined in `project.godot`, these are accessible globally by name:

| Autoload | File | Purpose |
|----------|------|---------|
| `GameManager` | `scripts/game_manager.gd` | Central hub — owns PlayerStats, SkillSystem, Inventory, EquipmentManager |
| `SaveSystem` | `scripts/save_system.gd` | Saves/loads to `user://knarfscape_save.json` |
| `QuestManager` | `scripts/quest_manager.gd` | Quest state tracking |
| `ChatLog` | `scenes/ui/chat_log.tscn` | In-game message log |
| `ItemsDatabase` | `data/items_database.gd` | Static item factory |

Access subsystems via `GameManager.stats`, `GameManager.skills`, `GameManager.inventory`, `GameManager.equipment`.

### Key Systems

- **SkillSystem** (`scripts/skill_system.gd`): 12 skills (hitpoints, attack, defence, strength, magic, ranged, woodcutting, mining, fishing, cooking, agility, thieving). Max level 50. Hitpoints starts at level 10 (OSRS-style). Signals: `skill_leveled_up`, `xp_gained`.

- **EquipmentManager** (`scripts/equipment_manager.gd`): Slots are `main_hand`, `off_hand`, `boots`. Damage and defence scale from equipped gear + skill levels.

- **Inventory** (`scripts/inventory.gd`): 28 slots with stackable items. Signals: `item_added`, `item_removed`, `inventory_changed`.

- **ResourceNode** (`scripts/resource_node.gd`): Base class for mineable/harvestable objects (Rock, Tree, Fish Spot). States: AVAILABLE → HARVESTING → DEPLETED → AVAILABLE. Subclasses override skill/XP/item configuration.

- **Item** (`scripts/item.gd`): Resource class with enums `ItemType`, `AttackStyle`, `EquipSlot`.

### Scene Structure

- **Entry point:** `scenes/world/main_world.tscn`
- **Player:** `scenes/player/player.tscn` — CharacterBody3D with SpringArm3D camera, WeaponHolder for visual meshes, HitBox Area3D for melee
- **Enemy:** `scenes/enemies/Enemy.tscn` — CharacterBody3D with NavigationAgent3D pathfinding, state machine (IDLE/PATROL/CHASE/ATTACK/DEAD)
- **UI scenes:** `scenes/ui/` — hud, skills_panel, inventory_ui, equipment_ui, chat_log, death_screen

### Communication Patterns

- **Signals**: Systems emit signals that other systems/UI subscribe to (e.g., `skill_leveled_up` → GameManager updates max HP → HUD refreshes)
- **Groups**: Nodes use Godot groups for dynamic lookups — `"players"`, `"enemies"`, `"npcs"`, `"resource_nodes"`, `"tombstones"`, `"skills_panel"`, `"inventory_ui"`, `"equipment_ui"`
- **ChatLog**: Use `ChatLog.add_message(text, type)` anywhere to log messages. Types: `"combat"`, `"xp"`, `"gather"`, `"quest"`, `"npc"`, `"death"`, `"system"`

### Player Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Shift | Run |
| Left Click | Attack |
| E | Interact (gather/talk) |
| Q | Toggle lock-on to nearest enemy |
| K | Skills panel |
| I | Inventory |
| Ctrl | Equipment panel |
| P | Toggle UI mouse mode |

### Adding New Content

- **New item**: Add a static factory method in `data/items_database.gd` returning an `Item` resource
- **New resource node**: Extend `ResourceNode`, set `skill_required`, `xp_reward`, `harvest_item_id`, `harvest_time`
- **New quest**: Instantiate `Quest` in `quest_manager.gd`, define objectives array, call `quest_manager.add_quest()`
- **New skill**: Add entry to `SkillSystem.skills` dictionary and handle XP/level-up logic
