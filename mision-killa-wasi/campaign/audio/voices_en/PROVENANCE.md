# English dialogue audio

These WAV files were generated locally from the English game text using the installed Microsoft Zira Desktop voice (English, United States) through Windows SAPI. Only rendered audio is included; Microsoft voice software is not redistributed.

`lines.json` records the text of each clip. A clip filename is the first 24 hexadecimal characters of the UTF-8 text's SHA-256 hash. Dialogue is split into pages of no more than 15 words before lookup. This allows fixed campaign dialogue to play without requiring an English system voice on the player's machine.

The shared English base recording is played with separate character pitch and rate profiles in `campaign/audio.gd`. See `ENGLISH_EDUCATION.md` for the profiles. These profiles should not be described as separate voice actors.

The collection contains some extra UI and hint lines as well as required dialogue. Human listening and child-comprehension testing remain useful for refining delivery.
