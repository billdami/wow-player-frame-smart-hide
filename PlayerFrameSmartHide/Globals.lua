local addonName, addon = ...;

addon.defaults = {
    ["options"] = {
        ["interactive"] = false,
        ["target"] = true,
        ["mouseover"] = false,
        ["instance"] = false,
        ["animate"] = false,
        ["opacity"] = 0
    }
};

addon.helpText = [[
Player Frame Smart Hide commands:
|cffeab517/playerframe help|r - Displays this list of commands
|cffeab517/playerframe settings|r - Displays the currently set option values
|cffeab517/playerframe interactive on|off|r |cffadadad(default: off)|r - Toggle player frame interactivity when hidden.
|cffeab517/playerframe target on|off|r |cffadadad(default: on)|r - Show the player frame when targeting.
|cffeab517/playerframe mouseover on|off|r |cffadadad(default: off)|r - Show the player frame on mouseover.
|cffeab517/playerframe instance on|off|r |cffadadad(default: off)|r - Show the player frame when in an instance.
|cffeab517/playerframe animate on|off|r |cffadadad(default: on)|r - Toggle fade out animation when hiding the player frame.
|cffeab517/playerframe opacity 0-100|r |cffadadad(default: 0)|r - The opacity % of the player frame when hidden.]];
