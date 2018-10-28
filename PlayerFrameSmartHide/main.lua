local addonName, addon = ...;
local P = "player";

local function isHealthOutsideThreshold()
    -- TODO make the threshold % a slash option
    return UnitHealth(P) < UnitHealthMax(P);
end

local function isPowerOutsideThreshold()
    -- TODO make the threshold % a slash option
    local power = UnitPower(P);
    local maxPower = UnitPowerMax(P);
    local powerId, powerType = UnitPowerType(P);
    local doesDecay = addon.decayPowerTypes[powerType];
    return (doesDecay and power > 0) or (not doesDecay and power < maxPower);
end

local function showPlayerFrame()
    PlayerFrame:SetAlpha(1);
    -- TODO make this a slash option
    PlayerFrame:EnableMouse(true);
end

local function hidePlayerFrame()
    PlayerFrame:SetAlpha(0);
    -- TODO make this a slash option
    PlayerFrame:EnableMouse(false);
end

local function togglePlayerFrame()
    -- show player frame if player has a target
    if UnitExists("target") then return showPlayerFrame(); end

    -- show player frame if player is in combat
    if UnitAffectingCombat(P) then return showPlayerFrame(); end

    -- show player frame if player health is < 100%
    if isHealthOutsideThreshold() then return showPlayerFrame(); end

    -- show player frame if player power is < 100% (or > 0 if its a decaying power type, e.g. rage)
    if isPowerOutsideThreshold() then return showPlayerFrame(); end

    -- otherwise, hide the player frame
    return hidePlayerFrame();
end

local function onEvent(self, event, arg1)
    if(event == "ADDON_LOADED" and arg1 == addonName) then
        if(not PfshOptions) then
            PfshOptions = addon.pfshDefaults["options"];
            print("Player Frame Smart Hide loaded. Type \"\/playerframe help\" to see available options.");
        end
    end

    togglePlayerFrame();
end

-- addon entry point
local mainFrame = CreateFrame("FRAME", "pfshMain");
mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
mainFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
mainFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
mainFrame:RegisterUnitEvent("UNIT_HEALTH", P);
mainFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", P);
mainFrame:SetScript("OnEvent", onEvent);
