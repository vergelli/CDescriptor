# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-04-19

### Added
- **Dynamic Prompt** — inline panel with language, content type (PvE/PvP with subcategory and difficulty), and role selectors. When enabled, a structured prompt is prepended to the JSON output, ready to paste directly into an LLM.
- **Auto-detected game version** — removed the manual patch input field; the API version is now read automatically via `GetAPIVersion()` and displayed in the window footer alongside the addon version.
- **Passive Skills** — new optional checkbox that exports a summary of learned vs. total passives per skill line.
- **Champion Points** — new optional checkbox that exports slottable and passive CP investments per discipline.
- ZOS licensing disclaimer added to manifest per ESOUI community requirements.

### Changed
- Gear JSON key order standardized across all slot types: `item → set → [weight] → quality → trait → enchant`.
- Perfected set handling: when both a base set and its perfected variant are equipped simultaneously, only the perfected entry is shown, with an accurate count of perfected pieces.
- SavedVariables migrated from a raw global to `ZO_SavedVars:NewAccountWide` — settings are now correctly scoped per account and server (EU/NA/PTS).
- Copy confirmation sound updated to the Group Ready Check notification sound.

### Fixed
- Prompt panel anchor conflict that rendered it on top of the Generate button and checkboxes instead of below them.
- Include Prompt checkbox was silently doing nothing — root cause was using `clickedCallback` instead of `ZO_CheckButton_SetToggleFunction`.
- Dropdown callbacks (`sub_combo_cb`, `diff_combo_cb`) were leaking into the global `_G` table; now correctly scoped as local upvalues via forward declaration.

## [1.2.0] - 2026-04-19

### Added
- Passive Skills and Champion Points adapters (data extraction layer).
- Scribing skill support: active scripts (a/b/c slots) with name and description are included inline with each skill entry.
- Scrollbar for the output box.
- Window resize persistence.

### Changed
- Output is now ordered using `__key_order` hints in the serializer, producing consistent field ordering across all sections.
- ESO color markup (`|cRRGGBB...|r`) is stripped from all text fields before serialization.

## [1.1.0] - 2026-04-19

### Added
- Optional sections: Combat Stats and Active Buffs, each toggled by a checkbox.
- Keybinding support via `bindings.xml`.
- Slash command `/cdescriptor`.

### Changed
- Gear section now distinguishes weapon, armor, and jewelry slot types.

## [1.0.0] - 2026-04-18

### Added
- Initial release.
- Exports character info, both action bars (skills + ultimate), and equipped gear as JSON.
- Optional Set Descriptions section (equipped set bonuses with piece counts).
- Single-click select-all for easy clipboard copy.
- Window position saved between sessions.
