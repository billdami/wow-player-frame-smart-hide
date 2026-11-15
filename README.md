# Player Frame Smart Hide

WoW addon that smartly hides the player frame

Project Homepage: https://www.curseforge.com/wow/addons/player-frame-smart-hide

## Compatibility

Targets the latest versions of World of Warcraft Retail, Classic, and Forever.

The player frame is shown while you have a target, are in combat, or mouseover it. Otherwise it is made invisible.

On Retail (12.x+ Midnight) and Forever, health and power values are secret, so thresholds cannot be compared. Instead, `/playerframe health on|off` and `/playerframe power on|off` show the frame while the player's health or power is changing (the `UNIT_HEALTH` / `UNIT_POWER_UPDATE` events), and hide it again if no such event fires for 2.1 seconds. Classic clients keep the percentage thresholds.

Protected mouse-setting changes are deferred during combat. If the frame was noninteractive before combat, it may remain noninteractive until combat ends, even though it is visible. Use `/playerframe interactive on` outside combat to keep it interactive while hidden as well.

## Settings

Use `/playerframe help` for all commands and `/playerframe settings` to inspect your settings. Existing per-character settings are preserved when upgrading.

## Validation

Run the mocked API regression tests from the repository root with Lua:

```sh
lua tests/standard.lua
lua tests/classic.lua
```

Alternatively, with Node.js installed:

```sh
npx --yes --package fengari-node-cli fengari tests/standard.lua
npx --yes --package fengari-node-cli fengari tests/classic.lua
```

The tests cover initialization, saved settings, health and power thresholds, secret values, combat lockdown, mouseover timer cleanup, resource update events, and slash commands. They do not emulate WoW's secure execution environment.

In-game validation is still required: enable Lua errors with `/console scriptErrors 1`, reload, and check targeting, entering/leaving combat, health and resource changes, mouseover, and zoning. Confirm there are no Lua errors or blocked-action messages.
