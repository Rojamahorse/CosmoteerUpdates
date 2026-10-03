# Data Folder Structure

Documentation for the `Data/` folder - the content and configuration heart of Cosmoteer.

## Overview

The `Data/` folder contains all game content, configuration, and assets defined in human-readable `.rules` files. This is the **data-driven core** of Cosmoteer - most game behavior, ship parts, UI, missions, and visual effects are defined here rather than in C# code.

**Entry Point:** `cosmoteer.rules` - The root data file that references all other game content.

See [Rules Syntax](Rules Syntax.md) for rules file syntax.

---

## Top-Level Structure

```
Data/
├── cosmoteer.rules          # Root data file - entry point for all game content
├── *.shader                 # DirectX HLSL shader files
├── ai/                      # Ship AI behaviors and decision-making
├── backgrounds/             # Space backgrounds and textures
├── buffs/                   # Buff type definitions
├── builtin_ships/           # Pre-built ships by faction
├── codex/                   # In-game tutorials and encyclopedia
├── commands/                # Ship fleet commands (move, follow, etc.)
├── common_effects/          # Shared particle effects, sounds, screen shake
├── crew/                    # Crew member definitions and behaviors
├── doodads/                 # Miscellaneous space objects
├── factions/                # NPC faction definitions
├── formations/              # Fleet formation patterns
├── galaxy_map/              # Galaxy/sector map configuration
├── gui/                     # User interface definitions
├── modes/                   # Game modes (Career, Creative, PvP)
├── music/                   # Music track definitions
├── name_generators/         # Procedural name generation rules
├── nebulas/                 # Nebula type definitions
├── planets/                 # Procedural background planet generators
├── post_shaders/            # Post-processing visual effects
├── resources/               # In-game resources (power, ammo, materials)
├── roof_decals/             # Cosmetic roof decorations
├── roof_textures/           # Roof texture assets
├── ships/                   # Ship classes and part definitions
├── shots/                   # Projectile and weapon shot definitions
├── statuses/                # Status effect type definitions
├── strings/                 # Localization and text strings
└── user_init/               # Copied to the user's home folder on first run
```

---

## Key Folders

### `ships/`
Ship classes and all buildable parts.

**Structure:**
```
ships/
├── base_ship.rules          # Base template for all ships
├── base_part.rules          # Base template for all parts
├── base_part_overclock.rules # Base template for overclockable parts
├── priorities.rules         # Common crew job priorities
├── common/                  # Shared part resources (sprites, sounds)
├── terran/                  # Human ship class and parts
│   ├── terran.rules         # Ship class definition
│   ├── corridor/            # Individual part folders
│   ├── reactor_small/
│   ├── cannon_large/
│   └── ...                  # 100+ part folders
├── asteroid/                # Asteroid ship class
└── megaroid/                # Megaroid ship class
```

**Key Concepts:**
- Each ship **class** (Terran, Asteroid, Megaroid) is a collection of compatible **parts**
- Parts are modular components: weapons, thrusters, reactors, armor, etc.
- `terran.rules` lists all available parts via `&<part_folder/part.rules>` references
- Each part folder contains: `.rules` definition, sprites, sounds, effects

### `modes/`
Game mode definitions and progression systems.

**Structure:**
```
modes/
├── career/                  # Career mode (main campaign)
│   ├── career.rules         # Career mode root
│   ├── encounters/          # Random encounter definitions
│   ├── sectors/             # Sector type definitions
├── creative/                # Creative/sandbox mode
│   └── creative.rules
└── pvp/                     # PvP multiplayer modes
    ├── pvp_elimination/     # Last ship standing
    ├── pvp_arena/           # Point-based arena combat
    ├── pvp_domination/      # Control point capture
    └── pvp_buildbattle/     # Build-then-battle mode
```

**Key Concepts:**

- Career mode includes progression, missions, encounters, rewards
- Each mode defines its own rules, UI, victory conditions

### `gui/`
All user interface definitions, menus, HUD elements.

**Structure:**
```
gui/
├── widgets.rules            # Reusable UI widget definitions
├── menus.rules              # Misc menu screen configuration
├── text_sprites.rules       # Sprites that can be embedded inline into text strings
└── game/                    # In-game UI (HUD, overlays)
    ├── game_gui.rules       # Game session UI root
    └── sim_gui.rules        # Simulation/sector UI root
```

**Key Concepts:**
- Widget-based component system
- Separate UI for menus vs. in-game
- Data-driven styling (but actual layout defined in C# code)

### `common_effects/`
Shared visual and audio effects used across the game.

**Structure:**
```
common_effects/
├── common_effects.rules     # Effect definitions index
├── base_shake.rules         # Screen shake templates
├── particles/               # Particle effect definitions
│   ├── explosions/          # Explosion particle effects
│   ├── bullet_trail_def.rules
│   ├── debris_def.rules
│   └── ...
└── sounds/                  # Common sound effects
    ├── common_sounds.rules
    ├── base_sounds.rules
    └── ...
```

**Key Concepts:**
- Reusable effect templates referenced by parts/weapons
- Explosion effects by size: small, medium, big, huge
- Particles, screen shake, and sounds bundled together

### `ai/`
Ship AI behaviors, targeting, and tactical decision-making.

**Contains:** AI state machines, targeting priorities, formation behaviors, threat assessment.

### `codex/`
In-game tutorial system and reference documentation.

**Structure:**
```
codex/
├── codex.rules              # Codex system root
└── tutorials/               # Tutorial mission definitions
    ├── build/               # Building tutorials
    ├── combat/              # Combat tutorials
    ├── crew/                # Crew management tutorials
    └── ...
```

### `builtin_ships/`
Pre-designed ships organized by faction.

**Structure:**
```
builtin_ships/
├── builtins.rules           # Index root of all builtin ships
├── Starter/                 # Tutorial starter ships
├── Imperium/                # Imperium faction ships
├── Fringe/                  # Fringe faction ships
├── Cabal/                   # Cabal faction ships
└── Monolith/                # Monolith faction ships
```

**Key Concepts:**

- Each folder contains `.ship.png` binary ship designs
- Ships are pre-built designs players can encounter or use
- Organized by faction/purpose

### `factions/`
NPC faction definitions: relationships, behaviors, spawn rules.

### `resources/`
In-game resource types (power, crew, ammo, fuel, etc.).

**Key Files:**
- `resources.rules` - Resource type definitions
- Includes special resources like `hyperium` (FTL fuel)
- Referenced by `cosmoteer.rules`: `Resources = &<resources/resources.rules>/Resources`

### `buffs/` & `statuses/`
Temporary or persistent effects applied to ships/parts.

**Difference:**
- **Buffs:** Abstract effects that can modify values and control part logic. Applied by parts or statuses.
- **Statuses:** Persistent conditions (fire, heat) that can often spread and can apply buffs and other effects.

### `backgrounds/`, `nebulas/`, `planets/`
Visual environment assets and definitions for space sectors.

### `post_shaders/`
Post-processing visual effects (bloom, color grading, etc.).

---

## Key Files

### `cosmoteer.rules`
**The root data file.** Defines global game settings and references all major systems:
- Effect buckets, crew, buffs, statuses
- Resources and FTL fuel type
- Factions, commands, formations
- Game modes (Career, Creative, PvP)
- Ships, AI, builtin ships
- GUI, shaders, music
- Simulation parameters (physics, camera, network)
- Game speed settings

### `ships/terran/terran.rules`
Defines the **Terran ship class** and all its buildable parts.

**Structure:**
- Ship metadata (ID, name, default parts)
- External walls and roof definitions
- Job associations (salvage, repair, construct)
- **Parts list** - references to 100+ individual part definitions

**Key Concept:** This is where all player-buildable parts are registered.

---

## Working with Data Files

### Adding New Content

**New Part:**
1. Create folder in `ships/terran/` (e.g., `my_weapon/`)
2. Create `my_weapon.rules` with part definition
3. Add sprites, sounds, effects to folder
4. Reference in `ships/terran/terran.rules`:
   ```
   &<my_weapon/my_weapon.rules>/Part
   ```

**New Ship Class:**
1. Create folder in `ships/` (e.g., `alien/`)
2. Create `alien.rules` extending `base_ship.rules`
3. Define parts list
4. Reference in `cosmoteer.rules`:
   ```
   Ships
   [
       &<ships/alien/alien.rules>/Alien
   ]
   ```

### Modding

- All content is data-driven and moddable
- Mods override/extend base game data
- Use unique IDs: `author_name.content_name`
- **Never use `cosmoteer.*` namespace for mods**

---

## Important Conventions

### File Naming
- Folders: `lowercase_with_underscores/`
- Rules files: `lowercase_with_underscores.rules`
- Ship designs: `Ship Name.ship.png`

### IDs and Namespacing
- Format: `author.content_name`
- Example: `cosmoteer.laser_blaster_small`
- Mods must use unique author names

### Asset Organization
- Keep all part assets in the part's folder or subfolders
- Use relative paths from the `.rules` file, or anchor to `./Data/` if going up more than 1-2 folder levels.
- Shared assets go in `ships/common/` or `common_effects/`

### Comments
- Document complex configurations
- Mark sections with clear headers

---

## Quick Reference

**Find a part definition:**
→ `ships/terran/[part_name]/[part_name].rules`

---

## See Also

- [Rules Syntax](Rules Syntax.md) - Detailed rules file syntax documentation
- `cosmoteer.rules` - Root data file with global references