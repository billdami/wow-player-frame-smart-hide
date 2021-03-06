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
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- if not then pre-populate them with the  defaults
        if not PfshOptions then
            PfshOptions = addon.defaults["options"];
            print("Player Frame Smart Hide loaded. Type \"\/playerframe help\" to see available options.");
        end
    end

    addon.togglePlayerFrame();
end);
