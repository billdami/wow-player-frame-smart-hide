# Player Frame Smart Hide

WoW addon that smartly hides the player frame

Project Homepage: https://wow.curseforge.com/projects/player-frame-smart-hide

## Compatibility

Targets World of Warcraft Retail 12.1.5 (interface `120105`). Classic clients are not supported.

The player frame is shown while you have a target, are in combat, or meet a configured health, power, or mouseover condition. Otherwise it is made transparent.

WoW 12.x can restrict health and power values as secret values. When an enabled threshold cannot be evaluated safely, the addon keeps the frame visible rather than inspecting restricted data. Normal threshold behavior resumes when the values are accessible again. A zero maximum health also keeps the frame visible; a resource with zero maximum power is ignored.

Protected mouse-setting changes are deferred during combat. If the frame was noninteractive before combat, it may remain noninteractive until combat ends, even though it is visible. Use `/playerframe interactive on` outside combat to keep it interactive while hidden as well.

## Settings

Use `/playerframe help` for all commands and `/playerframe settings` to inspect your settings. Existing per-character settings are preserved when upgrading.

## Validation

Run the mocked API regression tests from the repository root with Lua:

```sh
lua tests/compatibility.lua
```

Alternatively, with Node.js installed:

```sh
npx --yes --package fengari-node-cli fengari tests/compatibility.lua
```

The tests cover initialization, saved settings, health and power thresholds, secret values, combat lockdown, mouseover timer cleanup, resource update events, and slash commands. They do not emulate WoW's secure execution environment.

In-game validation is still required: enable Lua errors with `/console scriptErrors 1`, reload, and check targeting, entering/leaving combat, health and resource changes, mouseover, and zoning. Confirm there are no Lua errors or blocked-action messages.
