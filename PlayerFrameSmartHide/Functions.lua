local addonName, addon = ...;
local P = "player";
local mouseoverTicker;

local classicVersions = { 
    WOW_PROJECT_CLASSIC = true,
    WOW_PROJECT_BURNING_CRUSADE_CLASSIC = true,
    WOW_PROJECT_WRATH_CLASSIC = true,
    WOW_PROJECT_CATACLYSM_CLASSIC = true,
    WOW_PROJECT_MISTS_CLASSIC = true
}

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

local function isMouseOverPlayerFrame()
    local mouseover = PfshOptions["mouseover"] and true or false;
    if mouseover and PlayerFrame:IsMouseOver() then
        return true;
    else
        return false;
    end
end

local function showPlayerFrame()
    PlayerFrame:SetAlpha(1);
    if not InCombatLockdown() and not PlayerFrame:IsMouseEnabled() then
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

local function shouldShowPlayerFrame()
    -- show player frame if player has a target
    if UnitExists("target") then return true; end

    -- show player frame if player is in combat
    if InCombatLockdown() or UnitAffectingCombat(P) then return true; end

    -- show player frame if it is moused over
    if isMouseOverPlayerFrame() then return true; end

    -- classic editions only 
    if addon.isClassic() then
        -- show player frame if player health is < 100%
        if isHealthOutsideThreshold() then return true; end

        -- show player frame if player power is < 100% (or > 0 if its a decaying power type, e.g. rage)
        if isPowerOutsideThreshold() then return true; end
    end

    -- otherwise, hide the player frame
    return false;
end

local function updatePlayerFrame()
    if not PfshOptions or not PlayerFrame then return; end

    if shouldShowPlayerFrame() then
        showPlayerFrame();
    else
        hidePlayerFrame();
    end
end

addon.stopMouseoverTicker = function()
    if mouseoverTicker then
        mouseoverTicker:Cancel();
        mouseoverTicker = nil;
    end
end

addon.togglePlayerFrame = function()
    if not PfshOptions or not PlayerFrame then return; end

    updatePlayerFrame();

    if PfshOptions["mouseover"] then
        if not mouseoverTicker then
            mouseoverTicker = C_Timer.NewTicker(0.10, updatePlayerFrame);
        end
    else
        addon.stopMouseoverTicker();
    end
end

addon.isClassic = function() 
    return classicVersions[WOW_PROJECT_ID] and true or false;
end
