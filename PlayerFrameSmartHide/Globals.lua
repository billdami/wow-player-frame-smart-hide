local addonName, addon = ...;

addon.defaults = {
    ["options"] = {
        ["interactive"] = false,
        ["health"] = 100,
        ["power"] = false
    }
};

addon.helpText = [[
    Player Frame Smart Hide commands:
    /playerframe help - Displays this list of commands
    /playerframe settings - Displays the currently set option values
    /playerframe interactive on|off (default: off) - Toggle player frame interactivity when hidden.
    /playerframe health 0-100|off (default: 100) - The player health % below which the player frame will be hidden.
    /playerframe power 0-100|off (default: off) - The player power % below (or above for rage-like power types) which the player frame will be hidden.
]];

-- https://wow.gamepedia.com/PowerType
addon.decayPowerTypes = {
    ["RAGE"] = true,
    ["COMBO_POINTS"] = true,
    ["RUNIC_POWER"] = true,
    ["SOUL_SHARDS"] = true,
    ["LUNAR_POWER"] = true,
    ["HOLY_POWER"] = true,
    ["MAELSTROM"] = true,
    ["CHI"] = true,
    ["INSANITY"] = true,
    ["ARCANE_CHARGES"] = true,
    ["FURY"] = true,
    ["PAIN"] = true
};
