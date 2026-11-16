local addonName, addon = ...;
local P = "player";
local mouseoverTicker;

local function isInstanced()
    local inInstance, instanceType = IsInInstance()
    
    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena" or instanceType == "scenario") then
        return true;
    else
        return false;
    end
end

-- classic: compare health/power % against the configured thresholds
local function isHealthOutsideThreshold()
    local threshold = PfshOptions["health"];
    if not threshold then return false; end
    local pct = (UnitHealth(P) / UnitHealthMax(P)) * 100;
    return pct < threshold;
end

local function isPowerOutsideThreshold()
    local threshold = PfshOptions["power"];
    if not threshold then return false; end
    local pct = (UnitPower(P) / UnitPowerMax(P)) * 100;
    local powerId, powerType = UnitPowerType(P);
    local doesDecay = addon.decayPowerTypes[powerType];
    return (doesDecay and pct > threshold) or (not doesDecay and pct < threshold);
end

-- non-classic: health/power values are secret, so instead treat the frame as
-- "active" while the associated event keeps firing (it only fires when the value changes)
local ACTIVITY_TIMEOUT = 2.1; -- out of combat regen ticks every 2s
local activity = {
    UNIT_HEALTH = { options = { "health" } },
    UNIT_POWER_UPDATE = { options = { "power" } },
    -- the first regen event can take ~2s to fire after leaving combat, so hold the
    -- frame visible meanwhile to avoid a brief hide
    PLAYER_REGEN_ENABLED = { options = { "health", "power" } }
};

local function isAnyOptionOn(state)
    for _, option in ipairs(state.options) do
        if PfshOptions[option] then return true; end
    end
    return false;
end

local function stopActivityTimers()
    for _, state in pairs(activity) do
        if state.timer then
            state.timer:Cancel();
            state.timer = nil;
        end
        state.active = false;
    end
end

local function isResourceActive()
    for _, state in pairs(activity) do
        if state.active and isAnyOptionOn(state) then return true; end
    end
    return false;
end

local function isMouseOverPlayerFrame()
    local mouseover = PfshOptions["mouseover"] and true or false;
    if mouseover and PlayerFrame:IsMouseOver() then
        return true;
    else
        return false;
    end
end

local function isFrameVisible(frame)
    return not frame or frame:IsVisible();
end


local function showPlayerFrame()
    PlayerFrame:SetAlpha(1);
    if not InCombatLockdown() and not PlayerFrame:IsMouseEnabled() then
        PlayerFrame:EnableMouse(true);
    end
end

local function hidePlayerFrame()
    local interactive = PfshOptions["interactive"] and true or false;
    local opacity = PfshOptions["opacity"] or 0;

    if not InCombatLockdown() then
        PlayerFrame:EnableMouse(interactive);
    end

    PlayerFrame:SetAlpha(opacity);
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

    if addon.isClassic() then
        if isHealthOutsideThreshold() then return true; end
        if isPowerOutsideThreshold() then return true; end
    elseif isResourceActive() then
        return true;
    end

    return false;
end

local function updatePlayerFrame(event)
    if not PfshOptions or not PlayerFrame then return; end

    if shouldShowPlayerFrame() then
        showPlayerFrame();
    else
        hidePlayerFrame();
    end
end

-- non-classic: mark health/power as active and (re)start its expiry timer
local function noteResourceActivity(event)
    local state = activity[event];
    if not state or not isAnyOptionOn(state) then return; end

    state.active = true;
    if state.timer then state.timer:Cancel(); end
    state.timer = C_Timer.NewTimer(ACTIVITY_TIMEOUT, function()
        state.timer = nil;
        state.active = false;
        updatePlayerFrame("ACTIVITY_TIMEOUT");
    end);
end

addon.stopMouseoverTicker = function()
    if mouseoverTicker then
        mouseoverTicker:Cancel();
        mouseoverTicker = nil;
    end
end

addon.stopActivityTimers = stopActivityTimers;

addon.togglePlayerFrame = function(event)
    if not PfshOptions or not PlayerFrame then return; end

    if not addon.isClassic() then noteResourceActivity(event); end

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
