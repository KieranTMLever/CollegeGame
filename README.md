# Campus Quest 🎓

A 2D pixel art platformer built in **Godot 4**, set on a chaotic college campus. Collect all your study notes before time runs out — while dodging zombified students and electric hazards!

---

## How to Run

1. Download and install [Godot 4](https://godotengine.org/download).
2. Open Godot, click **Import**, and select the `project.godot` file in this folder.
3. Press **F5** or click the **Play** button.

---

## Game Features

| Feature | Details |
|---|---|
| 🏃 Controllable Character | Smooth 2D platformer movement with coyote-time jumping |
| 📓 Collectibles | Study notes (10 pts) & coffee cups (50 pts + speed boost) |
| 💀 Enemies | Zombie students that patrol platforms and turn at ledges |
| ⚡ Hazards | Electric spike strips — instant damage on contact |
| ❤️ Lives | 3 lives per run, shown on HUD |
| ⏱ Timer | Countdown per level; time bonus added on completion |
| 🗺 3 Levels | Library → The Labs → Finals Week (escalating difficulty) |
| 🎛 Difficulty | Normal / Hard toggle from main menu |
| 🏆 High Score | Persists between sessions |

---

## Main Menu

| Button | Action |
|---|---|
| **START GAME** | Begin from Level 1 |
| **DIFFICULTY** | Toggle Normal / Hard |
| **CONTROLS** | Rebind keyboard keys |
| **AUDIO** | Adjust Master / Music / SFX volume |
| **QUIT GAME** | Exit |

---

## Default Controls

| Action | Key |
|---|---|
| Move Left | `A` / `←` |
| Move Right | `D` / `→` |
| Jump | `Space` / `W` / `↑` |
| Pause | `Escape` |

All controls are rebindable in the **Controls** menu.

---

## Judging Category Notes

- **Fun Factor** — Coyote-time jumps, caffeine speed boosts, and escalating challenge across 3 levels.
- **Visual Identity** — Low-resolution pixel art (320×180) with a consistent dark-academic colour palette; all sprites are drawn procedurally in GDScript.
- **Narrative Storytelling** — You play as Alex, a sleep-deprived student, fighting through the Library, Labs, and Finals Week.
- **Audio Design** — Fully procedural chiptune BGM and SFX generated at runtime via `AudioStreamGenerator`; no external audio files required.
- **Innovative Accessibility** — Fully rebindable keybindings, adjustable audio levels (Master/Music/SFX), coyote-time for forgiving jumps, and high-contrast HUD.

---

## Project Structure

```
project.godot            Godot 4 project settings & input map
default_bus_layout.tres  3-bus audio layout (Master / Music / SFX)
scripts/
  GameData.gd            Autoload: score, lives, settings, save/load
  Audio.gd               Autoload: procedural BGM + SFX generation
  Player.gd              CharacterBody2D: movement, jump, invincibility
  Enemy.gd               Patrolling zombie student AI
  Collectible.gd         Floating study note / coffee cup
  Hazard.gd              Electric spike hazard
  ExitDoor.gd            Level-exit trigger (opens when all notes collected)
  HUD.gd                 Score, lives, timer, notifications
  Level.gd               Base level: procedural generation from data arrays
  Level1/2/3.gd          Level-specific layout data
  MainMenu.gd            Title screen
  ControlsMenu.gd        Keybinding remapper
  AudioMenu.gd           Volume sliders
  PauseMenu.gd           In-game pause overlay
  GameOver.gd            Win / Game Over screen
scenes/
  *.tscn                 Corresponding scene files
```
