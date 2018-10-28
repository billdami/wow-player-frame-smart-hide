local addonName, addon = ...;

SLASH_PLAYERFRAMEHIDE1 = "/playerframe";

function SlashCmdList.PLAYERFRAMEHIDE(msg, editBox)
    local command, value = strsplit(" ", msg);
    value = value.gsub(str, "%s+", "").lower();

    -- set interactive mode
    if command == "interactive" then
        if value == "on" then
            PfshOptions["interactive"] = true;
            print("Set interactive mode to ON");
        elseif value == "off" then
            PfshOptions["interactive"] = false;
            print("Set interactive mode to OFF");
        end
    -- set health threshold
    elseif command == "health" then
        if value == "off" then
            PfshOptions["health"] = false;
            print("Show on player health threshold set to OFF");
        else
            value = tonumber(value);
            if value and value > 0 and value < 100 then
                PfshOptions["health"] = value;
                print("Set player frame to show when player health is below " .. tostring(value) .. "%");
            end
        end
    -- set power threshold
    elseif command == "power" then
        if value == "off" then
            PfshOptions["power"] = false;
            print("Show on player power threshold set to OFF");
        else
            value = tonumber(value);
            if value and value > 0 and value < 100 then
                PfshOptions["power"] = value;
                print("Set player frame to show when player power is below (or above for rage-like types) " .. tostring(value) .. "%");
            end
        end
    -- display current setting values
    elseif command == "settings" then
        print("Interactive mode: " .. PfshOptions["interactive"] and "ON" or "OFF");
        print("Health threshold: " .. PfshOptions["health"] and tostring(PfshOptions["health"]) or "OFF");
        print("Power threshold: " .. PfshOptions["health"] and tostring(PfshOptions["health"]) or "OFF");
    -- show help text
    else
        print(addon.helpText);
    end

    -- trigger toggle frame logic to make sure new settings are applied
    addon.togglePlayerFrame();
end
