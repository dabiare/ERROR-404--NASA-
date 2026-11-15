# English edition: explain, act, and check

The active campaign is now presented in English: menus, crew dialogue, modes, rooms, map, activities, hints, item descriptions, encyclopedia, journal, resource labels, reports, save errors, and voice-preview controls. Killa Wasi remains the game's proper name. Player-chosen robot names remain unchanged. Spanish file names and stable inventory identifiers are internal data, not displayed terminology.

## Explain the purpose before every activity

Each task in `daily_data.gd` has a `why` field as well as its instruction and result. The crew explains the reason first, using a short analogy or consequence, then describes the action. For example:

- **Storage:** filters are dust-catching nets; matching codes makes the spare easy to find later.
- **Medical check:** readings help the doctor understand how the crew feels after travel.
- **Food:** grains provide energy, proteins support growth, and vegetables bring nutrients.
- **Calibration:** a faulty instrument is like a ruler with mixed-up marks.
- **Ventilation:** a clear vent lets the fan circulate stuffy air; a separate scrubber removes CO₂.
- **Spacesuits:** a suit is a tiny spacecraft that needs checks before leaving the base.
- **Field science:** a rock without notes loses part of its story.
- **Rover:** a wheel guard helps keep thrown-up dust off the crew and equipment.
- **Cleaning:** rough Moon dust can scratch equipment and contaminate living spaces.
- **Water:** the cartridge helps treat used water, like a strainer that needs replacement.
- **Exercise:** lower weight does not remove the need to care for muscles and bones.
- **Solar return:** people come first, even if samples must be left behind.
- **Airlock:** the procedure keeps the base's air inside.
- **Shelter:** shielding reduces exposure; the dosimeter measures radiation rather than blocking it.
- **Crew support and plants:** listening helps teammates; observations help us understand what plants need.

Briefing and dialogue pages remain at most 15 words. Essential definitions also appear on activity cards. Optional encyclopedia pages retain more detail and scientific source links. A complete activity is checked by its outcome, not just a generic instruction to try again.

## Storage example

The six cards explicitly represent equipment labels. Find the **AD-42 spare dust-filter box** and the **AD-42 shelf tag**. Water cartridges and other equipment have different codes and purposes. Matching both does not yet grant inventory: the player chooses **Store filter** to register one spare. A review button lets them look again.

AD-42 is a fictional game code, not a NASA standard. An air particle filter catches dust; it does not replace a CO₂ scrubber or a water cartridge.

## Modes

**Cadet — Learning explorer:** extra emergency time and friendly offers of hints. **Commander — Quicker challenge:** standard emergency timers. Both modes let the player lead the same crew, pause, practice, and request help; story and rewards are the same. The explanations fit within separate cards rather than relying on children already knowing the rank names.

## Character voices

English dialogue audio is included locally. The build machine's Godot voice interface exposed only Spanish voices, so the clips were generated using its installed **Microsoft Zira Desktop English (United States)** voice through Windows SAPI. No Windows voice installation or registry modification is needed to play the included clips.

These are distinct **tone and pace profiles**, not recordings by seven different actors:

| Character | Presentation | Pitch ratio | Playback rate |
|---|---|---:|---:|
| Commander | Steady and encouraging | 1.02 | 0.98 |
| Engineer | Lower and brisk | 0.87 | 1.07 |
| Botanist | Bright and lively | 1.18 | 1.08 |
| Doctor | Calm and slower | 0.91 | 0.86 |
| Geologist | Eager and energetic | 1.08 | 1.13 |
| Guide robot | Higher and electronic | 1.48 | 1.16 |
| Mission Control | Lower and measured | 0.79 | 0.93 |

An audio pitch effect separates pitch from playback rate. Spoken audio follows the voice-volume control, stops when dialogue is skipped or closed, and stops on focus loss. Blip remains an additional robot sound. Use **Options → Preview character voices** to listen to each profile.

`campaign/audio/voices_en/lines.json` contains the text used for the included clips. English system TTS is a fallback for a new uncached line, when available. The main campaign and its hints have bundled audio; tests report missing spoken lines rather than silently treating Spanish speech as English.

## Compatibility and testing

- Existing version-2 saves accept older Spanish mode names and display English names after loading. Crew role IDs and inventory keys stay stable.
- Native English signage covers the Spanish caption baked into the exterior image; the original bitmap and collision geometry remain intact. Decorative wall previews use unlabelled equipment artwork.
- Tests check a reason for every task, brief text length, distinct voice profiles, bundled English audio for all task briefings, storage confirmation, save compatibility, resource rules, and both complete campaign routes.
- The English keyboard tour completes all three days and checks that no spoken line is missing. Graphic checks cover both 1280×720 and 1920×1080, mode explanations, the storage confirmation step, voice preview, and existing rooms and interfaces.

Validation of this revision: **843 state/content checks passed**, both complete keyboard routes passed (**34 activities**), and **57 graphical captures** were inspected or audited across both resolutions. Seven pitch/rate profiles were checked using included English audio. The project contains **349 bundled English clips**, including dialogue, hints, and additional interface phrases.

This is a content and usability revision. Child comprehension, enjoyment, and campaign duration still need playtests with children; successful automated checks do not establish those outcomes.
