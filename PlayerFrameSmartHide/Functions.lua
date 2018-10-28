local addonName, addon = ...;
local P = "player";

local function isHealthOutsideThreshold()
    local threshold = PfshOptions["health"];
    if threshold then
        local hp = UnitHealth(P);
        local maxHP = UnitHealthMax(P);
        local pct = (hp / maxHP) * 100;
        return pct < threshold;
    else
        return false;
    end
end

local function isPowerOutsideThreshold()
    local threshold = PfshOptions["power"];
    if threshold then
        local power = UnitPower(P);
        local maxPower = UnitPowerMax(P);
        local pct = (power / maxPower) * 100;
        local powerId, powerType = UnitPowerType(P);
        local doesDecay = addon.decayPowerTypes[powerType];
        return (doesDecay and pct > threshold) or (not doesDecay and pct < threshold);
    else
        return false;
    end
end

local function showPlayerFrame()
    PlayerFrame:SetAlpha(1);
    if not PlayerFrame:IsMouseEnabled() then
        PlayerFrame:EnableMouse(true);
    end
end

local function hidePlayerFrame()
    local interactive = PfshOptions["interactive"] and true or false;
    if not InCombatLockdown() then
        PlayerFrame:EnableMouse(interactive);
    end
    PlayerFrame:SetAlpha(0);
end

addon.togglePlayerFrame = function()
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
