local addonName, addon = ...;

addon.defaults = {
    ["options"] = {
        ["interactive"] = false,
        ["mouseover"] = false,
        ["hideDelay"] = 2
    }
};

addon.helpText = [[
Player Frame Smart Hide commands:
|cffeab517/playerframe help|r - Displays this list of commands
|cffeab517/playerframe settings|r - Displays the currently set option values
|cffeab517/playerframe interactive on|off|r |cffadadad(default: off)|r - Toggle player frame interactivity when hidden.
|cffeab517/playerframe mouseover on|off|r |cffadadad(default: off)|r - Show the player frame on mouseover.
|cffeab517/playerframe hideDelay NUM|r |cffadadad(default: 2)|r - The delay in seconds before hiding the player frame (except for targeting) (set to 0 to disable).]];
