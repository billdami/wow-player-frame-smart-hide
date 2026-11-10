local addonName, addon = ...;

local mainFrame = CreateFrame("FRAME", "pfshMain");
mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
mainFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
mainFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
mainFrame:RegisterUnitEvent("UNIT_HEALTH", "player");
mainFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");

-- addon entry point
mainFrame:SetScript("OnEvent", function(self, event, arg1)
    -- when the addon is loaded check if its SavedVariables exist
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return; end

        -- if not then pre-populate them with the  defaults
        if not PfshOptions then
            PfshOptions = {};
            print("Player Frame Smart Hide loaded. Type \"/playerframe help\" to see available options.");
        end

        for option, default in pairs(addon.defaults["options"]) do
            if PfshOptions[option] == nil then
                PfshOptions[option] = default;
            end
        end
        
        self:UnregisterEvent("ADDON_LOADED");
        return;
    elseif event == "PLAYER_LEAVING_WORLD" then
        addon.stopMouseoverTicker();
        return;
    end

    -- ignore events for settings that are disabled
    if event == "UNIT_POWER_UPDATE" and not PfshOptions["power"] then
        return;
    end

    if event == "UNIT_HEALTH" and not PfshOptions["health"] then
        return;
    end

    if event == "PLAYER_TARGET_CHANGED" and not PfshOptions["target"] then
        return;
    end

    addon.togglePlayerFrame(event);
end);
