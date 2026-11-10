local addonName, addon = ...;

SLASH_PLAYERFRAMEHIDE1 = "/playerframe";

function SlashCmdList.PLAYERFRAMEHIDE(msg, editBox)
    local command, value = strsplit(" ", msg);
    value = value and string.gsub(string.lower(value), "%s+", "") or nil;

    -- set interactive mode
    if command:lower() == "interactive" then
        if value == "on" then
            PfshOptions["interactive"] = true;
            print("Set interactive mode to |cff9ed4ffON");
        elseif value == "off" then
            PfshOptions["interactive"] = false;
            print("Set interactive mode to |cff9ed4ffOFF");
        end
    -- set target mode
    elseif command:lower() == "target" then
        if value == "on" then
            PfshOptions["target"] = true;
            print("Set target mode to |cff9ed4ffON");
        elseif value == "off" then
            PfshOptions["target"] = false;
            print("Set target mode to |cff9ed4ffOFF");
        end
    -- set mouseover mode
    elseif command:lower() == "mouseover" then
        if value == "on" then
            PfshOptions["mouseover"] = true;
            print("Set mouseover mode to |cff9ed4ffON");
        elseif value == "off" then
            PfshOptions["mouseover"] = false;
            print("Set mouseover mode to |cff9ed4ffOFF");
        end
    -- set instance mode
    elseif command:lower() == "instance" then
        if value == "on" then
            PfshOptions["instance"] = true;
            print("Set instance mode to |cff9ed4ffON");
        elseif value == "off" then
            PfshOptions["instance"] = false;
            print("Set instance mode to |cff9ed4ffOFF");
        end
    -- set opacity level
    elseif command:lower() == "opacity" then
        value = tonumber(value);
        if value and value >= 0 and value < 100 then
            PfshOptions["opacity"] = value / 100;
            print("Set opacity level to |cff9ed4ff" .. tostring(value) .. "%");
        end
    -- set health threshold
    elseif command:lower() == "health" then
        if value == "off" then
            PfshOptions["health"] = false;
            print("Show on player health threshold set to |cff9ed4ffOFF");
        else
            value = tonumber(value);
            if value and value >= 0 and value <= 100 then
                PfshOptions["health"] = value;
                print("Set player frame to show when player health is below |cff9ed4ff" .. tostring(value) .. "%");
            end
        end
    -- set power threshold
    elseif command:lower() == "power" then
        if value == "off" then
            PfshOptions["power"] = false;
            print("Show on player power threshold set to |cff9ed4ffOFF");
        else
            value = tonumber(value);
            if value and value >= 0 and value <= 100 then
                PfshOptions["power"] = value;
                print("Set player frame to show when player power is below (or above for rage-like types) |cff9ed4ff" .. tostring(value) .. "%");
            end
        end
    -- display current setting values
    elseif command:lower() == "settings" then
        print("Player Frame Smart Hide settings:");
        print("Interactive mode: |cff9ed4ff" .. (PfshOptions["interactive"] and "ON" or "OFF"));
        print("Target mode: |cff9ed4ff" .. (PfshOptions["target"] and "ON" or "OFF"));
        print("Mouseover mode: |cff9ed4ff" .. (PfshOptions["mouseover"] and "ON" or "OFF"));
        print("Instance mode: |cff9ed4ff" .. (PfshOptions["instance"] and "ON" or "OFF"));
        print("Health threshold: |cff9ed4ff" .. (PfshOptions["health"] and tostring(PfshOptions["health"]) .. "%" or "OFF"));
        print("Power threshold: |cff9ed4ff" .. (PfshOptions["power"] and tostring(PfshOptions["power"]) .. "%" or "OFF"));
        print("Hidden opacity level: |cff9ed4ff" .. tostring(PfshOptions["opacity"] * 100) .. "%");
    -- show help text
    else
        print(addon.helpText);
    end

    -- trigger toggle frame logic to make sure new settings are applied
    addon.togglePlayerFrame();
end
