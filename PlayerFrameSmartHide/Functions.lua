local addonName, addon = ...;
local P = "player";
local mouseoverTicker;

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
