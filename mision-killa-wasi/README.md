# Mission Killa Wasi — English edition

An educational three-day lunar campaign for children, built with **Godot 4.7.2**, GDScript, and the Compatibility renderer. Team ERROR 404. The planned mission lasts thirty days; this playable campaign ends after day three.

## Open and play

1. Import **this folder's `project.godot`** in Godot 4.7.2.
2. Open the project and press **F5**.
3. Choose **New mission**, then read the two adventure-mode cards.

The parent folder's `Jugar.ps1` and root Godot project also launch this campaign. Close and reopen an already-open editor if it still uses an earlier configuration. The first import may take a few minutes because all artwork and English dialogue audio are included.

## Controls

| Action | Controls |
|---|---|
| Move the commander | WASD or arrow keys |
| Interact with nearby equipment or a door | E |
| Continue or reveal dialogue | Enter, Space, or Continue button |
| Task board and task record | T |
| Journal, cards, and badges | J |
| Interactive map | M |
| Optional robot help | R |
| Pause and options | Esc |
| Navigate ordinary buttons | Tab / Shift+Tab, then Enter; or mouse |

The task button shows **!** when there is news. It replaces the old objective text at the top center. Door names appear when approached. The map previews connected rooms and shows your actual position in your current room; it does not teleport you.

## Understand, act, and check

Before every activity, a crew member briefly explains why it matters, then explains what to do. Activity cards define objects and actions; stage instructions, feedback, and progress messages explain what changed. Read [ENGLISH_EDUCATION.md](ENGLISH_EDUCATION.md) for the content revision, including the distinction between dust filters, carbon-dioxide scrubbers, and water cartridges.

For example, storage cards represent box and shelf labels. Match the **AD-42 spare dust-filter box** with the **AD-42 shelf tag**, then choose **Store filter**. Matching the two labels does not grant a spare until you confirm storage.

Most activities use arrows and Enter or mouse selection. Calibration uses left/right to adjust and Enter to check. Vacuuming uses a selected section plus holding E, Space, or the mouse button. Rhythm exercise accepts alternating left/right or untimed practice using down and Enter; both earn the same card. Every activity supports free, optional robot help.

## Adventure modes and daily planning

**Cadet** is a learning explorer: extra emergency time and gentle offers of hints. **Commander** is a quicker challenge with standard emergency timers. Both let the player lead the same crew, practice, pause, and ask for help. The story and rewards are the same.

The three days have **3, 5, and 5 time blocks**. Choose the order among available tasks. Dependencies keep preparations ahead of outings, and essential tasks remain achievable. Emergencies do not consume blocks. Optional tasks, samples, crew conversations, cards, badges, and visual improvements reward exploration.

- **Day 1:** arrival, crew introductions, naming the robot, medical readings, meal planning, storage or laboratory preparation, and ventilation.
- **Day 2:** suit preparation, field science, a distant impact, rover dust-guard repair, cleaning, and an optional crew or science activity.
- **Day 3:** water-loop repair, exercise, another outing, solar-alert return, crew shelter, and a final report.
- Each night brings dinner and another clue about the robot's mysterious signal. After day three, the base remains available to explore.

Standard game timers are **90, 60, and 180 seconds**; Cadet multiplies them by 1.5. Timers run during active minigames and stop during briefings, help, pause, room transitions, and focus loss. They are game challenges, not real medical limits. If time runs out, teammates help and the campaign continues with a visible resource cost.

## Sound and voices

The supplied menu track loops during the menu and landing. Indoor music continues between rooms; outdoor music uses intervals; tension music replaces normal music during emergencies.

English dialogue clips are bundled in `campaign/audio/voices_en/`. They play locally without downloading voices. Characters have distinct pitch and pacing profiles; these are not recordings by seven separate actors. Use **Options → Preview character voices** to hear them individually. Voice volume controls narration and the additional robot Blip sound. English system speech is a fallback for a new line when available.

## Saves

The normal save is `user://campaign_v2.json`, usually `%APPDATA%\KillaWasi\campaign_v2.json` on Windows. Temporary writes and a valid `.bak` backup protect the preceding save. The campaign saves tasks, blocks, resources, mood, decisions, cards, robot name, mode, character state, position, emergency time, and activity progress.

After continuing, interact with the task equipment to resume its saved activity. Older version-two saves accept Spanish mode names and display English names after loading. Player-chosen robot names are preserved. Version-one linear-campaign saves are preserved separately and are not automatically converted. New mission asks before replacing current progress.

Previously delivered ZIPs are snapshots of older versions and do not automatically receive local changes.

## Code and resources

| Files | Purpose |
|---|---|
| `campaign/daily_data.gd` | Tasks, reasons, instructions, dialogue, dependencies, and text audit |
| `campaign/daily_mission.gd` | Campaign state, budgets, resources, decisions, rewards, emergencies, and saves |
| `campaign/daily_game.gd` | Story presentation, interactions, modes, nights, and day transitions |
| `campaign/daily_ui.gd` | Tasks, journal, encyclopedia, briefings, and voice preview |
| `campaign/minigame.gd` | Activities, controls, stage feedback, pause, and hints |
| `campaign/map_view.gd` | Room previews and actual player position |
| `campaign/catalog.gd`, `items_en.json` | English names, explanations, and source links for 26 systems and extra components |
| `campaign/room.gd`, `actor.gd` | Room construction, original terrain collisions, navigation, movement, NPC work, and reactions |
| `campaign/audio.gd` | Music, effects, bundled narration, and character voice profiles |
| `campaign/audio/voices_en/lines.json` | Source text for included English audio clips |

Original artwork, controller scenes, and earlier linear scripts remain available for reference. The campaign keeps the team's three walk frames at 8 fps, 200 px/s base speed, and exterior collision polygons. English signs are native overlays; original bitmaps remain intact.

## Verification

From the repository root:

```powershell
$godot = 'C:\Users\Domenick\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path mision-killa-wasi --editor --import --quit
& $godot --headless --path mision-killa-wasi -- --daily-test
& $godot --headless --path mision-killa-wasi --fixed-fps 60 -- --daily-tour
& $godot --path mision-killa-wasi -- --daily-visual
```

Tests use separate test-save files, not the normal campaign save. Graphics are captured in `artifacts/daily/`, excluded from Git. State tests check purpose-before-action, text limits, voice coverage, storage confirmation, compatibility, budgets, decisions, rescues, and saved activity progress. The keyboard tour completes both routes and checks for missing spoken lines. Visual checks cover 1280×720 and 1920×1080, readable mode cards, English screens, and actual playback with distinct pitch profiles.

The duration and difficulty targets remain subject to real playtests with children. Automated completion and content checks do not prove enjoyment, comprehension, or a 35–50-minute play time. Earlier validation records are preserved in `VALIDACION.md` and `REDISENO_DIARIO.md`; current English behavior is described in `ENGLISH_EDUCATION.md`.
