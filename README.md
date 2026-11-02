# Player Frame Smart Hide

WoW addon that smartly hides the player frame

Project Homepage: https://www.curseforge.com/wow/addons/player-frame-smart-hide

## Compatibility

Targets the latest versions of World of Warcraft Retail, Classic, and Forever.

The player frame is shown while you have a target, are in combat, or mouseover it. Otherwise it is made invisible.

WoW 12.x+ (Midnight) restricts health and power values as secret values. As such, this addon can no longer compare the player's current health/power against a set threshold in order to conditionally hide the (secure) default player frame. If you require this functionality, you will need to use other addons that completely replace the default frame.

Protected mouse-setting changes are deferred during combat. If the frame was noninteractive before combat, it may remain noninteractive until combat ends, even though it is visible. Use `/playerframe interactive on` outside combat to keep it interactive while hidden as well.

## Settings

Use `/playerframe help` for all commands and `/playerframe settings` to inspect your settings. Existing per-character settings are preserved when upgrading.

## Validation

Run the mocked API regression tests from the repository root with Lua:

```sh
lua Versions/Retail/tests/compatibility.lua
```

Alternatively, with Node.js installed:

```sh
npx --yes --package fengari-node-cli fengari Versions/Retail/tests/compatibility.lua
```

The tests cover initialization, saved settings, health and power thresholds, secret values, combat lockdown, mouseover timer cleanup, resource update events, and slash commands. They do not emulate WoW's secure execution environment.

In-game validation is still required: enable Lua errors with `/console scriptErrors 1`, reload, and check targeting, entering/leaving combat, health and resource changes, mouseover, and zoning. Confirm there are no Lua errors or blocked-action messages.
