local addonName, addon = ...;

-- TODO move slash commands into another file
SLASH_PLAYERFRAMEHIDE1 = "/playerframe";
function SlashCmdList.PLAYERFRAMEHIDE(msg, editBox)
    local command, value = strsplit(" ", msg);

    if command == "interactive" then
        value = value == "on" and true or false;
        print("set interactive mode to " .. (value and "ON" or "OFF"));
    elseif command == "health" then
        value = value == "off" and false or tonumber(value);
        print("set health threshold to " .. value or "OFF");
    elseif command == "power" then
        value = value == "off" and false or tonumber(value);
        print("set power threshold to " .. value or "OFF");
    else
        print(addon.helpText);
    end
end
