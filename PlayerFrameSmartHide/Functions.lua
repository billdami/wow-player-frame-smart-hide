local addonName, addon = ...;
local P = "player";
local mouseoverTicker;
local hideTicker;

local animateEvents = {
    ["PLAYER_REGEN_ENABLED"] = true,
    ["PLAYER_LEAVE_COMBAT"] = true,
    ["UNIT_HEALTH"] = true,
    ["UNIT_POWER_UPDATE"] = true
}

local function isInstanced()
    local inInstance, instanceType = IsInInstance()
    
    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena") then
        return true;
    else
        return false;
    end
end

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

local function hidePlayerFrame(animateOut)
    local interactive = PfshOptions["interactive"] and true or false;
    local opacity = PfshOptions["opacity"] or 0;

    if not InCombatLockdown() then
        PlayerFrame:EnableMouse(interactive);
    end

    if PfshOptions["animate"] and animateOut then
        UIFrameFadeOut(PlayerFrame, 0.3, PlayerFrame:GetAlpha(), opacity);
    else
        PlayerFrame:SetAlpha(opacity);
    end
end

local function shouldShowPlayerFrame()
    -- show the player frame if player is in an instance
    if PfshOptions["instance"] and isInstanced() then return true; end

    -- show player frame if player has a target
    if PfshOptions["target"] and UnitExists("target") then return true; end

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

local function updatePlayerFrame(event)
    if not PfshOptions or not PlayerFrame then return; end

    -- TODO if there was an in progress hide ticker, restart it if hiding on this new update
    local hasInProgressTicker = hideTicker and true or false;
    addon.stopHideTicker();

    if shouldShowPlayerFrame() then
        showPlayerFrame();
    else
        local hasDelay = PfshOptions["hideDelay"] and PfshOptions["hideDelay"] > 0;
        if (hasInProgressTicker or animateEvents[event]) and hasDelay then
            hideTicker = C_Timer.NewTicker(PfshOptions["hideDelay"], function() hidePlayerFrame(true); end, 1);
            return;
        else
            hidePlayerFrame(false);
        end
    end
end

addon.stopMouseoverTicker = function()
    if mouseoverTicker then
        mouseoverTicker:Cancel();
        mouseoverTicker = nil;
    end
end

addon.stopHideTicker = function()
    if hideTicker then
        hideTicker:Cancel();
        hideTicker = nil;
    end
end

addon.togglePlayerFrame = function(event)
    if not PfshOptions or not PlayerFrame then return; end

    updatePlayerFrame(event);

    if PfshOptions["mouseover"] then
        if not mouseoverTicker then
            mouseoverTicker = C_Timer.NewTicker(0.10, function() updatePlayerFrame("MOUSEOVER"); end);
        end
    else
        addon.stopMouseoverTicker();
    end
end

addon.isClassic = function() 
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then return true; end
	return false;
end
